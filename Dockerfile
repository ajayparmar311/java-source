# Create Custom Docker Image
# Pull tomcat latest image from dockerhub 
FROM tomcat:latest

# Maintainer
MAINTAINER "ajay parmar - iwayQ" 

# copy war file on to container 
COPY ./iwayq.war /usr/local/tomcat/webapps
