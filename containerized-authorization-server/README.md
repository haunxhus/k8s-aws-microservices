# Spring authorization server using OIDC implement

## About The Project

### About The Project

After
the [announcement about APIs related to Java has been deprecated ](https://www.keycloak.org/2022/02/adapter-deprecation)
in Keycloak, Spring released versions of Spring Cloud Authorization Server for authentication and authorization based on
Spring Security. This provided a solution to fill the gap caused by the deprecation of Keycloak's APIs.

What is being deprecated:

- ~~OpenID Connect Java adapters~~
- ~~OpenID Connect Node.js adapters~~
- ~~SAML Tomcat and Jetty adapters~~

What is not being deprecated:

- OpenID Connect client-side JavaScript adapter
- SAML WildFly and servlet filter

**Notices**: Spring Cloud Authorization Server is new, and therefore has fewer tutorials and less mature features.

### Build with:

- ![Java 17](https://img.shields.io/badge/Java17-ED8B00?style=for-the-badge&logo=java&logoColor=white)
- ![Spring framework 6.0](https://img.shields.io/badge/Spring%20framework%206.0-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)
- ![Spring boot 3.0](https://img.shields.io/badge/Spring%20boot%203.0-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)
- ![Spring authorization server 1.0](https://img.shields.io/badge/Spring%20authorization%20server%201.0-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)

## Getting Started

As I researched design patterns for using an authorization server, I found that the field mostly uses two patterns, as
shown in the images below:

**Spring gateway as the client server**

![Spring gateway as the client server](../assets/gw/gw-as-cli.png)

**Spring gateway as the resource server**

![Spring gateway as the resource server](../assets/gw/gw-as-res.png)

In this source we're using Spring Gateway as the resource server, because of reducing the heavy in configuration and
security logic in each service, we just need config and check in central place that means at the gateway.

![Implemented pattern](../assets/gw/chosen.png)

Implemented pattern

**Look deeper**

The OAuth 2.0 specification describes a number of grants (“methods”) for a client application to acquire an access
token (which represents a user’s permission for the client to access their data).

Spring OAuth2 predefined grant types:

- ClientCredentialsTokenGranter
- RefreshTokenGranter
- AuthorizationCodeTokenGranter
- ImplicitTokenGranter
- ResourceOwnerPasswordTokenGranter(it`s password grant type which one you use in example)

If you want to change token acquiring logic you can go with custom TokenGranter.

To run quickly with docker-compose just need to run maven command:

**Here we go**

Run with docker-compose

```shell
mvn clean install
docker-compose build --no-cache
docker-compose up --force-recreate
```

Run with docker-compose with multiple stage

```shell
docker-compose build -f docker-compose-v1.yml --no-cache
docker-compose up -f docker-compose-v1.yml --force-recreate
```

Run with docker-compose with jar

```shell
docker-compose build --no-cache
docker-compose up --force-recreate
```

Access into url:

```shell
curl --location 'localhost:8762/product/api/v1/products' \
--data ''
```

![unauth](../assets/gw/unauth.png)

```text
http://127.0.0.1:9000/oauth2/authorize?response_type=code&client_id=api-client&redirect_uri=http://127.0.0.1:8080/authorized&scope=api.read
```
`response_type=code` value may be one of "code" for requesting an authorization code or "token" for requesting an access
token (implicit grant).

`client_id=api-client`

`redirect_uri=http://127.0.0.1:8080/authorized`

`scope=api.read`

![](../assets/gw/login_page.png)

Login page

It'll redirect to

```text
http://127.0.0.1:8080/authorized?code=IlhhTB1tJIGUe654QbgF_-aShR1iwiVfdUe_TgGcc8Uwx_-8JRBmYJru_hGjVKGcvO4MvTjNXacmN9P9b1kKwJlgZ8Bvw7Rxos54WocF-rD17nbQLY-8_1ljeJ1xKsgh
```

if already granted accessibility or to consent page

![](../assets/gw/consent.png)

Get the string after `code` in url
param: `IlhhTB1tJIGUe654QbgF_-aShR1iwiVfdUe_TgGcc8Uwx_-8JRBmYJru_hGjVKGcvO4MvTjNXacmN9P9b1kKwJlgZ8Bvw7Rxos54WocF-rD17nbQLY-8_1ljeJ1xKsgh`

![](../assets/gw/got_code.png)

To get token pass the code and the other params like after:

Token Endpoint

![Token Endpoint](../assets/gw/got_token.png)

or curl

```shell
curl --location 'http://127.0.0.1:9000/oauth2/token' \
--header 'Authorization: Basic YXBpLWNsaWVudDpzZWNyZXQ=' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=authorization_code' \
--data-urlencode 'code=IlhhTB1tJIGUe654QbgF_-aShR1iwiVfdUe_TgGcc8Uwx_-8JRBmYJru_hGjVKGcvO4MvTjNXacmN9P9b1kKwJlgZ8Bvw7Rxos54WocF-rD17nbQLY-8_1ljeJ1xKsgh' \
--data-urlencode 'redirect_uri=http://127.0.0.1:8080/authorized'
```


```shell
curl --location 'localhost:8762/product/api/v1/products' \
--header 'Authorization: Bearer eyJraWQiOiI0YTMxZWM4Yi0wZjQyLTRhMTEtYmQ0Zi03Y2FjYjljNGExZWMiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJoaUB2bW9kZXYuY29tIiwiYXVkIjoiYXBpLWNsaWVudCIsIm5iZiI6MTY4MTcyMzU3MCwic2NvcGUiOlsiYXBpLnJlYWQiXSwiaXNzIjoiaHR0cDovL2NvbnRhaW5lcml6ZWQtYXV0aG9yaXphdGlvbi1zZXJ2ZXI6OTAwMCIsImV4cCI6MTY4MTcyNzE3MCwiaWF0IjoxNjgxNzIzNTcwfQ.hT3VMg4Cr_4HcWQQ28hwW5xzk9TkTzplqTiympLOG7uz-k8aidF6YkIHVFFFDF13gpG07mQ7fpVT8IzFBgE6dEJWe8fBCJwBNha0tkNvc0K32Gn0aQcb939OBG72cb2Kz1tBhyQ7FPZsmqZRYKOmcLJMv2dJt4_qux7xgg9IN3hSjaEbw5pS83tR3OV2TkdSNziMyKjdRQV2UAxD8dDwyJWRRaDY1QIXkepugaSIgiLPD_wRbWqjHwp9Qs-hwZxCeWHfxw13V5cdw--9mOsGq-2YIrPE2ZK7qEVKkL-Ce7fvR_QfwZqMh7UEN3N5r-ibDki-CgufozkbuklhOIToZQ' \
--data ''
```

![](../assets/gw/auth.png)

**Successfully**
