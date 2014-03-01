
#### SSH Security

In some of my previous documentation and scripts I had specified settings that ignored security risks, such as man-in-the-middle attacks.

Part of the reason for this is I use these documents to generate development machines which often run automated scripts.

Fortunately SSH can be told to use certain insecure features per commnad, such as:

    ssh -o StrictHostKeyChecking=no example.com

However, the question is whether or not all services I may use in scripts offer similar "options" flags.
