FROM python:3.6
ADD . /app
WORKDIR /app
#RUN apt-get update -y && \
#   apt-get install curl -y && \
#   apt-get install vim -y
RUN pip install  --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org  -r requirements.txt
RUN python setup.py install
CMD ["k8s-snapshots"]
