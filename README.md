# Linode Node Balancer command line tool

This is a command line tool to cover a common use case. Specifically, suppose you have 2 servers (called server1 and server2 in the Linode Manager) as members of a NodeBalancer, and each of them is listening on ports 80 and 443. When you want to do maintenance on server1, it's quite a lot of clicks in the Linode Manager to accomplish this.

So using this tool, you can do

    loadbalancer server1 reject

This will take server1 completely out of rotation in the NodeBalancer, on all ports it is listening on.  To bring it back online, use

    loadbalancer server2 accept

Which will bring it back.

In both cases, it will loop waiting for the change to actually propogate; when it has completed, and your changes have taken effect, the tool exits.

Uses the most excellent [Linode gem](https://github.com/rick/linode); you'll need to install that gem first using

    gem install linode

Then add your Linode API key to the file, make it executable in your file system, remove the .rb extension if you want, and you're good to go.