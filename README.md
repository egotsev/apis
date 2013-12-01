OAuth4Susi
===
OAuth4Susi is an OAuth 2.0 Authorization Server currently for providing oauth
for [the susi parser](https://github.com/NikolaDimitroff/SusiParser)
It is based on [apis](https://github.com/OpenConextApps/apis).

## Getting Started

To build the entire project

    mvn clean install

You need to have [maven 3](http://maven.apache.org/download.html) installed.


## Run Authorization Server

Go the authorization-server-war and start the application

    cd apis-authorization-server-war
    mvn jetty:run

The authorization-server-war application is capable of authenticating Resource
Owners (e.g. users) and granting and validating Access Tokens (and optional
Refresh Tokens) on behalf of Resource Servers that are receiving resource calls
from a Client app. It also offers a JavaScript application to manage Resource
Servers and Client application instances.

