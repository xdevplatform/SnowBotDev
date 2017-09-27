# Script for managing Welcome Messages

## Setting up Welcome Messages

* *set_welcome_messages.rb* script that makes requests to the Twitter Direct Message API. 
* Takes one or two command-line parameters. 

```
Usage: setup_welcome_message [options]
    -w, --default WELCOME            Default Welcome Management: 'create', 'set', 'get', 'delete'
    -r, --rule RULE                  Welcome Message Rule management: 'create', 'get', 'delete'
    -i, --id ID                      Message or rule ID
    -h, --help                       Display this screen.
```

-w "create"

```
Creating Welcome Message...
error code: 403 #<Net::HTTPForbidden:0x007ff29903f230>
Errors occurred.
{"code"=>151, "message"=>"There was an error sending your message: Field description is not present in all options."}
```



setup_welcome_message --w "set" -i 883450462757765123


<What the story here? when one option did not have a description, this error is triggered:>





setup_welcome_message -w "delete" -i 883450462757765123

```
Deleting Welcome Message with id: 883450462757765123.
Deleted message id: 883450462757765123
```

-w "get"

```
Getting welcome message list.
Message IDs: 
Message ID 890789035756503044 with message: ❄ Welcome to snowbot ❄ 
Message ID 893578135685406724 with message: ❄ Welcome to snowbot ❄ 
Message ID 893579774534209539 with message: ❄ Welcome to snowbot (ver. 0.02) ❄ 
```

Here we see some debris... The one with the versioned message is the current one, and the other two are early ones that can be deleted. Note that there are common use-cases where you need multiple welcome messages, such as a 'under maintenance' message. This is not such a use-case, so let's go ahead and delete the unwanted welcome messages.

-w "delete" -i 890789035756503044

```
Deleting Welcome Message with id: 890789035756503044.
Deleted message id: 890789035756503044
```
-w "delete" -i 893578135685406724

```
Deleting Welcome Message with id: 893578135685406724.
Deleted message id: 893578135685406724
```

If you try to delete an unexisting Welcome Message ID: 

-w "get"

```
Getting welcome message list.
Message IDs: 
Message ID 893579774534209539 with message: ❄ Welcome to snowbot (ver. 0.02) ❄ 
```

### Setting the default Welcome Message

-r "get"

```
Getting welcome message rules list.
No rules exist.
```
Setting the default Welcome Message
-w "set" -i 893579774534209539

```
Setting default Welcome Message to message with id 893579774534209539...
```

-r "delete" -i 870397618781691904

## Validate setup
