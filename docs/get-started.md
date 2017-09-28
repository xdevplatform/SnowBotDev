
# Tutorial: Building a Twitter DM system with Ruby and Sinatra
### *Building the snowbot*
#### Tags: DMAPI, AAAPI, Ruby, WebApp, Sinatra

# Introduction
The purpose of this tutorial is to help developers get started with the Twitter Account Activity (AA) and Direct Message (DM) APIs. These APIs are used to build Direct Message *bots*, automated systems that respond to incoming Direct Messages. These systems receive webhook events from Twitter, process the received messages, and respond to the requester. 

+ By integrating with the Account Activity (AA) API you are developing a consumer of webhook events sent from Twitter. 
+ By integrating the Direct Message (DM) API, you are building the private communication channel for your bot users. 

For this tutorial, we are going to build a *snow bot*, a Twitter-based gateway for all kinds of snow-related information. It would be fun to have a Twitter account supply current weather and snow data, send Direct Messages with snow photos, and provide a curated list of web sites for learning more about snow science. 

So, this tutorial will walk us through the steps of designing, building and deploying a bot. The material below is split into several pieces including tips on getting started, utilities for managing API configurations, and various code examples to illustrate working with the API. 

Much of the narrative is language-agnostic, yet includes many code examples written in Ruby. Since these code examples are very short and have comments, we can consider them as pseudo-code. Pseudo-code that hopefully illustrates fundamental concepts that are readily implemented in non-Ruby languages.

We'll start off with a how to get started with these APIs.

# Getting Started

First off, if you haven't checked-out the DM and AA API documentation, that's the place to start. 

+ https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/overview
+ https://developer.twitter.com/en/docs/direct-messages/beta-features

If you are new to building bots with these APIs, please check out our [](). As described there, here are the steps for getting started: 
* Getting access keys to use when authenticating Twitter API requests.


* Deploying a web app that integrates both APIs. 
  * By integrating with the Account Activity (AA) API you are developing a consumer of webhook events sent from Twitter. 
  * By integrating the Direct Message (DM) API, you are building the private communication channel to your bot users. The AA API prodives the ability to listen for Twitter account activities, and the DM API enables you to send messages back to your users. 


As outlined [HERE](https://dev.twitter.com/webhooks/getting-started), here are the steps to take to set up access to, and the 'plumbing' of, the Account Activity API.

## Getting API access
+ Create a Twitter Application, and have it enabled with the Account Activity API. For now, you'll need to apply for Account Activity API access [HERE](https://gnipinc.formstack.com/forms/account_activity_api_configuration_request_form).

## Building webhook event consumer app
[Intro to why these scripts are needed and an overview of how/when used. "As a AA API client, I need to a tool to update my default Welcome Message. I need to set one up to get started, and also will update it as my bot evolves and add new features.] 

+ Deploy web app with an endpoint to handle incoming webhook events.
  + POST method that handles incoming Activity Account webhook events
  + GET method that implements CRC authentication requirements.
 
+ Subscribe your consumer web app using the Account Activity API
  + https://dev.twitter.com/webhooks/reference/post/account_activity/webhooks

+ Create a default Welcome Message.

+ Handle CRC event.

## Setting up Account subscriptions

## Setting up Welcome Messages

### Setting Default Welcome Message

### Designing your Quick Replies
