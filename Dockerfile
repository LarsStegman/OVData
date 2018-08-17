FROM mdillon/postgis
RUN apt-get update
RUN apt-get -y install python3 python3-pip
COPY requirements.txt /conf/requirements.txt
RUN pip3 install -r /conf/requirements.txt
COPY src/database/init/z0_init.sql /docker-entrypoint-initdb.d/
