import requests
import json
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

USERNAME = 'admin'
PASSWORD = 'admin'

def get_projects_response(repo, branch):
    project_key = 'com.tsys' + ':' + repo + ':' + branch 
    url = 'https://sonar-test.tools.tsys.aws/api/project_branches/list?project={project_key}'.format(project_key=project_key)
    r = requests.get(url, auth=(USERNAME, PASSWORD), verify=False).json()
    print(r)


def delete_project(repo, branch):
    project_key = 'com.tsys' + ':' + repo + ':' + branch
    url = 'https://sonar-test.tools.tsys.aws/api/projects/delete?project={project_key}'.format(project_key=project_key)
    try:
        r = requests.post(url, auth=(USERNAME, PASSWORD), verify=False)
    except:
        r.raise_for_status()
    # r.raise_for_status()
        # print(r.status_code())

# get_projects_response('accountissuingcommercialprovider', 'dpcm_ts1_june19')
# delete_project('commercialcredentialapi', 'dpcm_ind_sprint18')