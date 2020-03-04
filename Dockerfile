#Download base image form ubuntu on latest version
FROM ubuntu:latest

#Define home directory as root
RUN mkdir /root/jenkins/
ENV HOME /root/jenkins

#====================================Configure PROXY ==============================================
#ENV http_proxy "http://mmagallanes:1234567890Qwertyuiop@proxy.indra.es:8080"
#ENV https_proxy "https://mmagallanes:1234567890Qwertyuiop@proxy.indra.es:8080"
#ENV ftp_proxy "ftp://mmagallanes:1234567890Qwertyuiop@proxy.indra.es:8080"
#ENV no_proxy "github.alm.europe.cloudcenter.corp"
	
#====================================Update, add tools wget adn unzip, install jdk, install git================================
#Update libraries and install Git and jdk-8
RUN apt-get update \
    && apt-get upgrade -y \
# Install wget and unzip
    && apt-get install -y wget \
	&& apt-get install unzip \
# Install git
    && apt-get install -y git \
	&& git config --global http.https://github.alm.europe.cloudcenter.corp.sslverify false \
# Install JDK 8
    && apt-get install -qy openjdk-8-jdk






#==================================Install and configure maven=======version 3.5.4==============================
ARG MAVEN_VERSION=3.5.4

RUN cd /usr/local/src/ \
	&& wget http://www-us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
	&& tar -xf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
	&& mv apache-maven-${MAVEN_VERSION}/ apache-maven/

#Configure environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64		
ENV	M2_HOME /usr/local/src/apache-maven
ENV	MAVEN_HOME /usr/local/src/apache-maven
ENV PATH ${M2_HOME}/bin:${JAVA_HOME}/bin:${PATH}

#Add setting and keystore  (Esto quizas no pueda ir en la imagen del contenedor, pues es susceptible de cambiar)
COPY settings.xml ${MAVEN_HOME}/conf/

#=================================Install Chrome==============================================
# Google Chrome
RUN apt-get install -y gnupg gnupg2 gnupg1 \
	&& wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update -qqy \
	&& apt-get -qqy install google-chrome-stable \
	&& rm /etc/apt/sources.list.d/google-chrome.list \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
	&& sed -i 's/"$HERE\/chrome"/"$HERE\/chrome" --no-sandbox/g' /opt/google/chrome/google-chrome



ARG CHROME_DRIVER_VERSION=76.0.3809.68
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
	&& rm -rf /opt/chromedriver \
	&& unzip /tmp/chromedriver_linux64.zip -d /opt \
	&& rm /tmp/chromedriver_linux64.zip \
	&& mv /opt/chromedriver /opt/chromedriver_linux \
	&& chmod 775 /opt/chromedriver_linux \
	&& ln -fs /opt/chromedriver_linux /usr/bin/chromedriver




#==================================Install Firefox and geckodriver==============================================
# Firefox
#=========
#Selenium 3.5 only suport firefox versions between 55 to 62
ARG FIREFOX_VERSION=60.0 

RUN apt-get update -y && \
    apt-get -y --no-install-recommends install firefox && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*  && \
    wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/es-ES/firefox-$FIREFOX_VERSION.tar.bz2 && \
    apt-get -y purge firefox && \
    rm -rf /opt/firefox && \
    tar -C /opt -xjf /tmp/firefox.tar.bz2 && \
    rm /tmp/firefox.tar.bz2 && \
    mv /opt/firefox /opt/firefox-$FIREFOX_VERSION && \
    ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox


#============
# GeckoDriver
#============
#Selenium 3.5 only suport geckodriver versions between 0.17.0 to 0.20.1
ARG GECKODRIVER_VERSION=0.20.0
RUN wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VERSION/geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz && \
    rm -rf /opt/geckodriver && \
    tar -C /opt -zxf /tmp/geckodriver.tar.gz && \
    rm /tmp/geckodriver.tar.gz && \
    mv /opt/geckodriver /opt/geckodriver_linux && \
    chmod 775 /opt/geckodriver_linux && \
    ln -fs /opt/geckodriver_linux /usr/bin/geckodriver

#==================================Add Salve======================================================================
#Add slave
RUN mkdir ${HOME}/agent/
COPY agent.jar ${HOME}/agent/

