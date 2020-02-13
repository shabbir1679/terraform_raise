import requests
import json
import urllib3
# import allbranches
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import os
import sys

USERNAME = 'opsadmin'
PASSWORD = 'opsAdmin'
NEXUS_BASE_URL = 'https://nexus-old.tools.tsys.aws/service/rest/v1'
# REPOSITORY = 'releases'
# GROUP = 'com.tsys.enterprise'
# FORMAT = 'maven2'
# NAME = 'accountissuingcommercialprovider'
# VERSION = 'tcs_reqcorr_july19'



def get_components_response(name, version, repository, format):
    headers = {'Content-Type': 'application/json'}
    url = '{NEXUS_BASE_URL}/search?repository={repository}&version={version}&name={name}&format={format}'.format(NEXUS_BASE_URL=NEXUS_BASE_URL,repository=repository,version=version,name=name,format=format)
    r = requests.get(url, auth=(USERNAME, PASSWORD), headers=headers, verify=False).json()
    response = r
    comp_id = response['items'][0]['id']
    print(comp_id)
    resp = requests.delete(f'{NEXUS_BASE_URL}/components/{comp_id}', auth=(USERNAME, PASSWORD), verify=False)
    print(resp)

# get_components_response('accountissuingapi', 'test10', 'images', 'docker')