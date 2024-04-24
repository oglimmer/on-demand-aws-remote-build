# on demand aws remote build

Here is the problem:

I needed an ARM64 container for my Raspberry Pi. If I build, for example, picz on my Intel laptop (via buildx), it takes 33 minutes 😦

On a 4-core/16GB machine in AWS, the build takes about 5 minutes. However, you don't want to have such a machine running all the time if you only need it twice a month.

So I automated it:

- Step 1: Start an EC2 instance with Terraform.
- Step 2: Install Docker and Git with Ansible and log in to my private Docker registry.
- Step 3: Copy a build script to the host, and it simply does docker build && docker push.
- Step 4: Delete the EC2 instance with Terraform.

Put all of this into a bash script, and now I have a 5-minute ARM build that only costs me a few cents.
