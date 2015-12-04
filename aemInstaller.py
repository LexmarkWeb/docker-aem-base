import subprocess
import signal
import os
import sys
import psutil
import json
import requests

from time import sleep
from optparse import OptionParser
from requests.exceptions import ConnectionError
from simplejson.scanner import JSONDecodeError

# Argument definition
usage = "usage: %prog [options] arg"
parser = OptionParser(usage)
parser.add_option("-i", "--install_file", dest="filename",
                  help="AEM install file")
parser.add_option("-r", "--runmode",
                  dest="runmode",help="Run mode for the installation")
parser.add_option("-p", "--port", dest="port",
                  help="Port for instance")

options, args = parser.parse_args()
optDic = vars(options)

# Copy out parameters
print optDic
print optDic['filename']
fileName = optDic.setdefault('filename','cq-publish-4503.jar')
runmode = optDic.setdefault('runmode','publish')
port = optDic.setdefault('port','4503')

baseUrl = "http://localhost:" + port

def allBundlesRunning():
    session = requests.Session()
    session.trust_env = False
    body = session.get(baseUrl + "/system/console/bundles/.json", auth=('admin', 'admin')).json()
    allBundlesRunning = True
    for bundle in body["data"]:
        if bundle["state"] != "Active" and bundle["state"] != "Fragment":
            allBundlesRunning = False
            break
    return allBundlesRunning


# Starts AEM installer
installProcess = subprocess.Popen(['java', '-jar', fileName, '-r',runmode,'nosample','-p',port])
successfulStart = False

while 1:
    try:
        if allBundlesRunning() == True:
            successfulStart = True
            break
    except (ConnectionError, JSONDecodeError):
        sleep(1)

#Post install hook
postInstallHook = "postInstallHook.py"
if os.path.isfile(postInstallHook):
    print "Executing post install hook"
    returncode = subprocess.call(["python", postInstallHook])
    print returncode
else:
    print "No install hook found"


print "Stopping instance"
#
# If the success message was recieved, attempt to close all associated
# processes.
#
if successfulStart == True:
  parentAEMprocess= psutil.Process(installProcess.pid)
  for childProcess in parentAEMprocess.get_children():
    os.kill(childProcess.pid,signal.SIGINT)

  os.kill(parentAEMprocess.pid, signal.SIGINT)

  installProcess.wait()
  sys.exit(0)
else:
  installProcess.kill()
  sys.exit(1)
