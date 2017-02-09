
# ssh security

In some of my previous documentation and scripts I had specified settings that ignored security risks, such as man-in-the-middle attacks.

Part of the reason for this is I use these documents to generate development machines which often run automated scripts.

Fortunately SSH can be told to use certain insecure features per command, such as:

    ssh -o StrictHostKeyChecking=no example.com

However, the question is whether or not all services I may use in scripts offer similar "options" flags.


## automation

The purpose of a password on an ssh key is so that if someone gains temporary direct access to your system they are still unable to impersonate you or copy your ssh key.

If you are not concerned about physical access, you can automate loading your ssh key by creating one with an empty password, _or_ by storing your password in a file and sending that to `stdin` when loading your ssh key.
