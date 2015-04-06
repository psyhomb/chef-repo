#!/usr/bin/env python 

__prog__ = 'surfer'
__version__ = '0.3'
__description__ = 'General purpose Web service checker.'
__author__ = 'Janos Guljas <janos@vast.com>'


import os
import re
import sys
import gzip
import stat
import time
import base64
import signal
import socket
import urllib
import urllib2
import httplib
import smtplib
import optparse
import platform
import mimetools
import mimetypes
import datetime
from cStringIO import StringIO
from urlparse import urlparse, urlunparse
from cookielib import CookieJar, DefaultCookiePolicy
from email.MIMEText import MIMEText
from email.Header import Header
from email.Utils import parseaddr, formataddr
try:
    import json
except ImportError:
    import simplejson as json


DEFAULTS = {
    'timeout': 20,
    'warn_timeout': None,
    'critical_timeout': None,
    'cookies': True,
    'redirections': True,
    'threshold': 3,
    'headers__user-agent': ' '.join([__prog__, __version__]),
    'logging__base_path': '/data/nagios/surfer',
}

OK = 0
WARNING = 1
CRITICAL = 2
UNKNOWN = 3 

CONF_FILENAME = 'surfer.json'

LOG_WIDTH = 80

THRESHOLD_UPPER_BOUND = 10

LOGS_MODE = 0777

OPTIONS_TYPES = {
    'timeout': (int,),
    'warn_timeout': (int,),
    'critical_timeout': (int,),
    'cookies': (bool,),
    'redirections': (bool,),
    'threshold': (int,),
    'headers__user-agent': (str, unicode),
    'ssl_key': (str, unicode),
    'ssl_cert': (str, unicode),
    'usl': (str, unicode),
    'post': (dict, str, unicode),
    'tests': (dict,),
    'username': (str, unicode),
    'password': (str, unicode),
    'email_to': (list, tuple),
}

TESTS_TYPES = {
    'strings': (list,),
    'strings_not': (list,),
    'regexes': (list,),
    'regexes_not': (list,),
}

SMTP_SERVER = 'localhost'
if platform.node().lower() in [
        'ops',
    ]:
    SMTP_SERVER = 'smtp.vast.com'


def lstrips(string, prefix):
    if prefix and string.startswith(prefix):
        string = string[len(prefix):]
    return string


def any(iterable):
    for element in iterable:
        if element:
            return True
    return False


class HTTPSClientAuthHandler(urllib2.HTTPSHandler):

    def __init__(self, key, cert):
        urllib2.HTTPSHandler.__init__(self)
        self.key = key
        self.cert = cert

    def https_open(self, req):
        return self.do_open(self.getConnection, req)

    def getConnection(self, host, *args, **kwargs):
        return httplib.HTTPSConnection(host, key_file=self.key, cert_file=self.cert)


class Callable:
    def __init__(self, anycallable):
        self.__call__ = anycallable


class MultipartPostHandler(urllib2.BaseHandler):

    handler_order = urllib2.HTTPHandler.handler_order - 10

    def http_request(self, request):
        data = request.get_data()
        if data is not None and not isinstance(data, (unicode, str)):
            v_files = []
            v_vars = []
            try:
                 for(key, value) in data.items():
                     if type(value) == file:
                         v_files.append((key, value))
                     else:
                         v_vars.append((key, value))
            except TypeError:
                systype, value, traceback = sys.exc_info()
                raise TypeError, "not a valid non-string sequence or mapping object", traceback
            if len(v_files) == 0:
                data = urllib.urlencode(v_vars, True)
            else:
                boundary, data = self.multipart_encode(v_vars, v_files)
                contenttype = 'multipart/form-data; boundary=%s' % boundary
                request.add_unredirected_header('Content-type', contenttype)
            request.add_data(data)
        return request

    def multipart_encode(vars, files, boundary=None, buffer=None):
        if boundary is None:
            boundary = mimetools.choose_boundary()
        if buffer is None:
            buffer = StringIO()
        for (key, value) in vars:
            buffer.write('--%s\r\n' % boundary)
            buffer.write('Content-disposition: form-data; name="%s"' % str(key))
            buffer.write('\r\n\r\n' + str(value) + '\r\n')
        for (key, fd) in files:
            file_size = os.fstat(fd.fileno())[stat.ST_SIZE]
            filename = os.path.basename(fd.name)
            contenttype = mimetypes.guess_type(filename)[0] or \
                          'application/octet-stream'
            buffer.write('--%s\r\n' % boundary)
            buffer.write('Content-disposition: form-data; name="%s"; '\
                         'filename="%s"\r\n' % (str(key), filename))
            buffer.write('Content-type: %s\r\n' % contenttype)
            buffer.write('Content-length: %s\r\n' % file_size)
            fd.seek(0)
            buffer.write('\r\n')
            buffer.write(fd.read())
            buffer.write('\r\n')
        buffer.write('--%s--\r\n\r\n' % boundary)
        return boundary, buffer.getvalue()
    multipart_encode = Callable(multipart_encode)
    https_request = http_request


class PermissiveCookiePolicy(DefaultCookiePolicy):

    def set_ok(self, cookie, request):
        return True


class Surfer:

    def __init__(self, env, hostname=None, display_hostname=True, logging=None):
        self.hostname = hostname
        self.display_hostname = display_hostname
        self.env = self.validate_env(env)
        self.request_index = 0
        self.threshold = self.get_threshold()
        self.logging = str(logging).lower()
        self.performance_data = []
        self.exit_code = OK
        self.opener = urllib2.OpenerDirector()
        self.opener.add_handler(urllib2.ProxyHandler())
        self.opener.add_handler(urllib2.UnknownHandler())
        self.opener.add_handler(urllib2.HTTPHandler())
        self.opener.add_handler(urllib2.FTPHandler())
        self.opener.add_handler(urllib2.FileHandler())
        self.opener.add_handler(urllib2.HTTPDefaultErrorHandler())
        self.opener.add_handler(urllib2.HTTPErrorProcessor())
        self.opener.add_handler(MultipartPostHandler())
        self.cookie_jar = CookieJar(policy=PermissiveCookiePolicy())
        if self.get('cookies', True):
            self.opener.add_handler(urllib2.HTTPCookieProcessor(self.cookie_jar))

    def __del__(self):
        try:
            self.opener.close()
        except Exception:
            pass

    def get(self, name, default=None):
        output = default
        try:
            data = self.env.get('requests', [])[self.request_index].get(name)
        except IndexError or AttributeError:
            data = None
        if not data == None:
            output = data
        elif not self.env.get(name) == None:
            output = self.env.get(name)
        elif not DEFAULTS.get(name) == None:
            output = DEFAULTS.get(name)
        if type(output) == str:
            output = unicode(output, 'utf8', errors='replace')
        return output

    def get_headers(self):
        headers = {}
        request_env = {}
        try:
            request_env = self.env.get('requests', [])[self.request_index]
        except IndexError:
            pass
        host_env = {}
        try:
            hosts_env = self.env.get('hosts', {})
            for key, value in hosts_env.items():
                if self.hostname in key.split() and type(value) == dict:
                    host_env = value
                    break
        except IndexError:
            pass
        request_host_env = {}
        try:
            request_hosts_env = self.env.get('requests', [])[self.request_index].get('hosts', {})
            for key, value in request_hosts_env.items():
                if self.hostname in key.split() and type(value) == dict:
                    request_host_env = value
                    break
        except IndexError:
            pass
        for dictionary in (DEFAULTS, self.env, request_env, host_env, request_host_env):
            for key, value in dictionary.items():
                if key.startswith('headers__'):
                    headers[lstrips(key, 'headers__')] = value
        return headers

    def get_post(self):
        post = self.get('post') or {}
        if not isinstance(post, dict):
            return post
        files = self.get('files') or {}
        for key, value in files.items():
            post[key] = file(value, 'rb')
        return post or None

    def validate_env(self, env):
        if type(env) != dict:
            raise Exception('Environment container must be a dictionary object')
        if not env.has_key('url') ^ env.has_key('requests'):
            raise Exception('Only one of the "url" or "requests" keys expected')
        if env.has_key('url'):
            if not type(env.get('url')) in (str, unicode):
                raise Exception('Value of the "url" key must be a string')
        if env.has_key('requests'):
            requests = env.get('requests')
            if type(requests) != list:
                raise Exception('Value of the "requests" must be a list')
            for request in requests:
                if type(request) != dict:
                    raise Exception('All "requests" list items must be a dictionary objects')
                if not request.has_key('url'):
                    raise Exception('All "requests" list items must have an "url" key')
                if not type(request.get('url')) in (str, unicode):
                    raise Exception('Value of the "url" key must be a string')
        for option, types in OPTIONS_TYPES.items():
            if env.has_key(option):
                if not type(env.get(option)) in types:
                    raise Exception('Type of the "%s" is not from %s' % (option, types))
            for request in env.get('requests', []):
                if request.has_key(option):
                    if not type(request.get(option)) in types:
                        raise Exception('Type of the "%s" under "requests" is not from %s' % (option, types))
        if env.has_key('tests'):
            for test, types in TESTS_TYPES.items():
                if env.has_key(test):
                    if not type(env.get(test)) in types:
                        raise Exception('Type of the "%s" is not from %s' % (test, types))
        for request in env.get('requests', []):
            if request.has_key('tests'):
                for test, types in TESTS_TYPES.items():
                    if request.has_key(test):
                        if not type(env.get('requests', {}).get(test)) in types:
                            raise Exception('Type of the "%s" under "requests" is not from %s' % (test, types))
        if env.has_key('post'):
            if isinstance(env.get('post'), dict):
                for key, value in env.get('post', {}).items():
                    if not type(value) in (str, unicode):
                        raise Exception('Type of the "%s" must be string' % key, types)
        for request in env.get('requests', []):
            if request.has_key('post'):
                if isinstance(request.get('post'), dict):
                    for key, value in request.get('post', {}).items():
                        if not type(value) in (str, unicode):
                            raise Exception('Type of the "%s" must be string' % key, types)
        if env.has_key('ssl_cert'):
            ssl_cert = env.get('ssl_cert', '')
            if not os.path.isfile(ssl_cert):
                raise Exception('Unknown ssl_cert file %s' % ssl_cert)
        if env.has_key('ssl_key'):
            ssl_key = env.get('ssl_key', '')
            if not os.path.isfile(ssl_key):
                raise Exception('Unknown ssl_key file %s' % ssl_key)
        for request in env.get('requests', []):
            if request.has_key('ssl_cert'):
                ssl_cert = request.get('ssl_cert', '')
                if not os.path.isfile(ssl_cert):
                    raise Exception('Unknown ssl_cert file %s' % ssl_cert)
            if request.has_key('ssl_key'):
                ssl_key = request.get('ssl_key', '')
                if not os.path.isfile(ssl_key):
                    raise Exception('Unknown ssl_key file %s' % ssl_key)
        return env

    def get_threshold(self):
        threshold = self.get('threshold', 1)
        if threshold < 1:
            return 1
        if threshold > THRESHOLD_UPPER_BOUND:
            return THRESHOLD_UPPER_BOUND
        return threshold

    def add_performance_data(self, label, value):
        label = label.replace('=', '_').replace('&', '_').replace('\'', '_').replace('"', '_').replace(' ', '_')
        self.performance_data.append((label, "%ss" % value))

    def get_performance_data(self):
        output = ''
        labels = []
        for label, value in self.performance_data:
            label = label.strip()[:214]
            i = 1
            while label in labels:
                label += '__' + str(i)
                i += 1
            labels.append(label)
            output += "'%s'=%s; " % (label, value)
        return output

    def opener_remove_handler(self, handler_class):
        handlers = []
        for handler in self.opener.handlers:
            if not isinstance(handler, handler_class):
                handlers.append(handler)
        self.opener.handlers = handlers
        return len(self.opener.handlers)

    def alarm_handler(self, signum, frame):
        raise IOError('Request TIMEOUT')

    def test_data(self, data):
        strings = self.get('tests', {}).get('strings')
        strings_not = self.get('tests', {}).get('strings_not')
        regexes = self.get('tests', {}).get('regexes')
        regexes_not = self.get('tests', {}).get('regexes_not')
        output = {
            'ok': True,
            'messages': [],
        }
        if not any((strings, strings_not, regexes, regexes_not)):
            output['messages'].append('No tests')
            return output
        data = data.lower()
        if type(strings) in (str, unicode): strings = [strings]
        if type(strings_not) in (str, unicode): strings_not = [strings_not]
        if type(regexes) in (str, unicode): regexes = [regexes]
        if type(regexes_not) in (str, unicode): regexes_not = [regexes_not]
        for string in (strings or []):
            if not string.encode('utf-8').lower() in data:
                output['ok'] = False
                output['messages'].append('String "%s" not found' % string)
        for string_not in (strings_not or []):
            if string_not.encode('utf-8').lower() in data:
                output['ok'] = False
                output['messages'].append('String "%s" found' % string_not)
        for regex in (regexes or []):
            if not re.compile(r'%s' % regex.encode('utf-8'), re.I).search(data):
                output['ok'] = False
                output['messages'].append('Regex "%s" not matched' % regex)
        for regex_not in (regexes_not or []):
            if re.compile(r'%s' % regex_not.encode('utf-8'), re.I).search(data):
                output['ok'] = False
                output['messages'].append('Regex "%s" matched' % regex_not)
        if output['ok'] == True:
            output['messages'].append('All passed')
        return output

    def get_timeout(self, response_time):
        output = None
        warn_timeout = self.get('warn_timeout', None)
        if warn_timeout:
            if response_time >= warn_timeout:
                output = 'WARNING'
        critical_timeout = self.get('critical_timeout', None)
        if critical_timeout:
            if response_time >= critical_timeout:
                output = 'CRITICAL'
        return output

    def log(self, string, base_path, file_name):
        path = os.path.join(base_path, datetime.datetime.now().strftime('%Y/%m/%d/%H'))
        if not os.path.isdir(path):
            os.makedirs(path)
            os.chmod(path, LOGS_MODE)
        f = gzip.open(os.path.join(path, '%s.gz' % file_name), 'ab')
        if type(string) in (str, unicode):
            f.write(string.encode('utf8', 'replace') + '\n')
        f.close()

    def tag_now(self, format='%s', offset=0):
        """Example:
        {{ now:format=%Y-%m-%d,offset=86400 }}
        """
        return (datetime.datetime.now() + datetime.timedelta(seconds=int(offset))).strftime(str(format))

    def template_parser(self, string):
        for tag in re.findall(r"({{\s+([\w\d]*)(?:([^}]*))\s+}})", string):
            tag_string = tag[0]
            tag_name = tag[1]
            tag_kwargs = {}
            for kwarg in tag[2].lstrip(':').split(','):
                if kwarg:
                    key, value = kwarg.split('=')
                    tag_kwargs[str(key)] = value
            function = getattr(self, 'tag_%s' % tag_name)
            if not function:
                raise Exception('Unknown tag name %s' % tag_name)
            string = string.replace(tag_string, function(**tag_kwargs))
        return string

    def request(self):
        if self.request_index < 0:
            return None
        output = {
            'status': '',
            'log': [],
            'error': None,
        }
        hostname_string = ''
        if self.hostname != None:
            hostname_string = ' = %s' % self.hostname
        output['log'].append((' Request %s%s = %s ' % (
            self.request_index + 1,
            hostname_string, datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        )).center(LOG_WIDTH, '='))
        label = ''
        if self.hostname != None and self.display_hostname:
            label += ('%s: ' % self.hostname)
        raw_url = self.template_parser(self.get('url'))
        label += urlunparse(urlparse(raw_url))
        output['status'] = label
        output['log'].append(' URL '.center(LOG_WIDTH, '-'))
        output['log'].append(urlunparse(urlparse(raw_url)))
        o = urlparse(raw_url)
        hostname = (self.hostname or '').split(':')[0] or (o[1] or '').split(':')[0]
        try:
            ip = socket.gethostbyname(hostname)
            output['log'].append(' IP '.center(LOG_WIDTH, '-'))
            output['log'].append(ip)
        except socket.gaierror:
            pass
        try:
            port = o[1].split(':')[1]
        except IndexError:
            port = None
        if port:
            netloc = '%s:%s' % (hostname, port)
        else:
            netloc = hostname
        url = urlunparse((o[0], netloc, o[2], o[3], o[4], o[5]))
        post = self.get_post()
        if self.get('force_post'):
            post = self.get_post() or {}
        request_ = urllib2.Request(
            url=url,
            data=post,
            headers=self.get_headers(),
        )
        output['log'].append(' Request '.center(LOG_WIDTH, '-'))
        output['log'].append('%s %s' % (request_.get_method(), url))
        request_.add_header("host", o[1].split(':')[0])
        username = self.get('username')
        password = self.get('password')
        if username and password:
            request_.add_header("Authorization",
                                "Basic %s" % base64.encodestring('%s:%s' % \
                                             (username, password))[:-1])
        ssl_key = self.get('ssl_key')
        ssl_cert = self.get('ssl_cert')
        self.opener_remove_handler(HTTPSClientAuthHandler)
        self.opener_remove_handler(urllib2.HTTPSHandler)
        if ssl_key and ssl_key:
            self.opener.add_handler(HTTPSClientAuthHandler(ssl_key, ssl_cert))
        else:
            self.opener.add_handler(urllib2.HTTPSHandler())
        self.opener_remove_handler(urllib2.HTTPRedirectHandler)
        if self.get('redirections', True):
            self.opener.add_handler(urllib2.HTTPRedirectHandler())
        output['log'].append(' Request Headers '.center(LOG_WIDTH, '-'))
        for key, value in request_.headers.items():
            output['log'].append('%s: %s' % (key, value))
        if request_.data:
            output['log'].append(' POST Data '.center(LOG_WIDTH, '-'))
            if isinstance(request_.data, dict):
                output['log'].append(urllib.urlencode(request_.data))
            else:
                output['log'].append(request_.data)
        if self.cookie_jar._cookies:
            output['log'].append(' Cookies '.center(LOG_WIDTH, '-'))
            for domain, paths in self.cookie_jar._cookies.items():
                for path, cookies in paths.items():
                    for name, cookie in cookies.items():
                        output['log'].append('%s=%s; domain=%s; path=%s; '\
                            'expires=%s; secure=%s' % (
                                cookie.name,
                                cookie.value,
                                cookie.domain,
                                cookie.path,
                                datetime.datetime.fromtimestamp(cookie.expires or 0),
                                cookie.secure
                            )
                        )
        response = None
        signal.signal(signal.SIGALRM, self.alarm_handler)
        try_no = 1
        while try_no <= self.threshold:
            urlerror = None
            response_data = ''
            test_messages = ''
            timeout_str = ''
            response_time = 0
            attempts = ''
            log = []
            if try_no > 1:
                attempts = ' (%s attempts)' % try_no
            end_time = None
            try:
                signal.alarm(int(self.get('timeout')) or 60)
                start_time = time.time()
                response = self.opener.open(request_)
                end_time = time.time()
                signal.alarm(0)
                response_time = end_time - start_time
                result = {}
                result['headers'] = unicode(response.headers)
                result['status'] = '%s %s' % (response.msg ,response.code)
                unicode_data = ""
                try:
                    unicode_data = unicode(response.read(), 'utf8', errors='replace')
                except socket.error, error:
                    raise IOError, error
                result['data'] = unicode_data
                log.append(' Response Headers '.center(LOG_WIDTH, '-'))
                log.append(result['headers'])
                log.append(' Response Data '.center(LOG_WIDTH, '-'))
                log.append(result.get('data'))
                log.append(' Connection Status '.center(LOG_WIDTH, '-'))
                log.append(result['status'])
                test_result = self.test_data(result['data'])
                test_messages = ', '.join(test_result.get('messages', 'Unknown reason'))
                if not test_result.get('ok', False):
                    urlerror = test_messages
                    raise IOError, 'Test error'
                else:
                    timeout = self.get_timeout(response_time)
                    if timeout:
                        timeout_str = ' Response time %s' % timeout
                    log.append(' Response Time '.center(LOG_WIDTH, '-'))
                    log.append('%.2f%s' % (response_time, timeout_str))
                    log.append(' Tests '.center(LOG_WIDTH, '-'))
                    log.append('%s%s' % (test_messages, attempts))
                    output['status'] += ' %s%s' % (result['status'], timeout_str)
            except IOError, urlerror:
                signal.alarm(0)
                response_time = (end_time or time.time()) - start_time
                if try_no == self.threshold:
                    if hasattr(urlerror, 'reason'):
                        output['error'] = test_messages or urlerror.reason
                    else:
                        output['error'] = test_messages or urlerror
                    timeout = self.get_timeout(response_time)
                    if timeout:
                        timeout_str = ' Response time %s' % timeout
                    if hasattr(urlerror, 'headers'):
                        log.append(' Response Headers '.center(LOG_WIDTH, '-'))
                        log.append(unicode(urlerror.headers))
                    log.append(' Response Time '.center(LOG_WIDTH, '-'))
                    log.append('%.2f%s' % (response_time, timeout_str))
                    if str(urlerror) == 'Test error':
                        log.append(' Tests '.center(LOG_WIDTH, '-'))
                    else:
                        log.append(' Connection Status '.center(LOG_WIDTH, '-'))
                    log.append('%s%s' % (output['error'], attempts))
                    output['status'] += ' Failed! %s%s%s' % (output['error'], attempts, timeout_str)
            if not urlerror:
                break
            signal.alarm(0)
            try_no += 1
        output['log'] += log
        output['log'].append('-' * LOG_WIDTH)
        if (self.logging == 'errors' and urlerror) or self.logging == 'all':
            log_text = u''
            for l in output['log']:
                if type(l) in (str, unicode):
                    log_text += l + '\n'
            self.log(log_text, self.get('logging__base_path', '.'),
                     self.get('logging__file_name', hostname))
        if timeout == 'WARNING':
            self.exit_code = WARNING
        if output['error']:
            self.exit_code = CRITICAL
        if timeout == 'CRITICAL':
            self.exit_code = CRITICAL
        output['exit_code'] = self.exit_code
        self.add_performance_data(label, "%.2f" % response_time)
        self.request_index += 1
        if not self.env.has_key('requests') or \
           len(self.env.get('requests', [])) <= self.request_index:
            self.request_index = -1
        return output


def sendmail(subject, body, to, server=SMTP_SERVER, from_email='noreply@vast.com'):

    msg = MIMEText(body.encode('utf8', 'replace'), 'plain', 'utf8')
    msg['From'] = formataddr(('Vast Surfer', from_email))
    msg['To'] = ','.join(to)
    msg['Subject'] = Header(subject.encode('utf8', 'replace'), 'utf8')

    server = smtplib.SMTP(server)
    server.sendmail(from_email, to, msg.as_string())
    server.quit()


def main():
    options_parser = optparse.OptionParser(
        description=__description__,
        prog=__prog__,
        version=__version__,
        usage="%prog -e ENVIRNMENT [hostname, ...]"
    )
    options_parser.add_option('--environment', '-e', help='Select environment '\
        'to test. This value could be any toplevel dictionary key form the '\
        'JSON configuration. This is a mandatory option.')
    options_parser.add_option('--configuration', '-c', help='Path of the '\
        'configuration file. By default file surfer.json in the current '\
        'directory is used.')
    options_parser.add_option('--logging', '-l',
        help='Enable logging to a file. Possible values are "all" and "errors". '\
        'Even if there are logging parameters '\
        'in configuration, this option needs to be specified to enable logging')
    options_parser.add_option('--verbose', '-v',
        help='Display headers and content. Ignored if Nagios compatible '\
        'output is enabled.', action='store_true')
    options_parser.add_option('--nagios', '-n',
        help='Nagios compatible output.', action='store_true')
    options_parser.add_option('--mail', '-m',
        help='Send email on error if `email_to` option is specified.', action='store_true')
    options, arguments = options_parser.parse_args()
    arguments = arguments or [None]
    if len(arguments) > 0 and options.environment:
        exit_code = OK
        performance_data = ''
        conf_filename = (options.configuration or '').strip('"') or CONF_FILENAME
        environment = options.environment.strip('"')
        if not conf_filename.startswith('/'):
            if os.path.islink(__file__):
                root_dir = os.path.dirname(os.readlink(__file__))
            else:
                root_dir = os.path.realpath(os.path.dirname(__file__))
            conf_filename = os.path.join(root_dir, conf_filename)
        try:
            conf = json.load(open(conf_filename))
            if not type(conf) == dict:
                raise Exception('Expecting dictionary as toplevel object')
            if not environment in conf.keys():
                raise Exception('No "%s" dictionary key' % environment)
        except Exception, exception:
            raise Exception("Configuration %s, %s%s" % (
                conf_filename,
                str(exception)[0].lower(),
                str(exception)[1:]
            ))
        if str(options.logging).lower() not in ('all', 'errors', 'none'):
            raise Exception('Only "all" or "errors" are valid values for logging.')
        env = conf[environment]
        verbose = options.verbose
        if options.nagios:
            verbose = False
        email_body = []
        for hostname in arguments:
            surfer = Surfer(env, hostname, len(arguments) > 1, options.logging)
            while True:
                response = surfer.request()
                if response == None:
                    break
                if verbose:
                    for line in response.get('log', []):
                        print line
                else:
                    if options.nagios:
                        print response.get('status') + '; ',
                    else:
                        print response.get('status')
                if response.get('exit_code') == CRITICAL:
                    email_body.append(' ERROR '.center(LOG_WIDTH, '-'))
                    email_body.append(response.get('status'))
                    email_body += response.get('log', [])
                    email_body.append("")
                    email_body.append("")
                    email_body.append("")
            if exit_code < surfer.exit_code:
                exit_code = surfer.exit_code
            performance_data += surfer.get_performance_data()
        if options.nagios:
            print "| %s" % performance_data
        if options.mail and exit_code == CRITICAL and email_body:
            kwargs = {
                'subject': "Alert: %s (%s)" % (environment, conf_filename),
                'body': u'\n'.join(email_body),
                'to': surfer.get('email_to', []),
            }
            sendmail(**kwargs)
        return exit_code
    else:
        options_parser.print_help()
        return UNKNOWN

if __name__ == '__main__':
    out = UNKNOWN
    try:
       out = main()
    except Exception, exception:
        print >> sys.stdout, exception
    sys.exit(out)

