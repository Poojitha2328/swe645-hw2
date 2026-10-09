# SWE645 – Assignment 1
**Name:** Poojitha Nasappa

## Contents
```
index.html      Homepage (Part 1)
survey.html     Student Survey form (Part 2)
error.html      Custom error page
assets/style.css   Shared stylesheet
assets/hero.svg    Homepage illustration
README.md       This file
```

## Live URLs
- **S3 static website:** `http://poojitha-swe645-hw1.s3-website.us-east-2.amazonaws.com/`
- **EC2 web server:** `http://18.191.207.11/`

---

## Part A — Deploy to Amazon S3 static website hosting

1. **Create the bucket**
   - AWS Console → S3 → *Create bucket*.
   - Bucket name must be globally unique, e.g. `ravi-swe645-hw1` (lowercase,
     no spaces). Choose a region close to you, e.g. `us-east-1`.
   - Under *Object Ownership*, leave ACLs disabled (default). Under *Block
     Public Access settings*, **uncheck "Block all public access"** and
     acknowledge the warning — the site needs to be publicly readable.

2. **Upload the site files**
   - Open the bucket → *Upload* → add `index.html`, `survey.html`,
     `error.html`, and the `assets/` folder (drag the whole folder so the
     `assets/style.css` and `assets/hero.svg` paths are preserved).

3. **Turn on static website hosting**
   - Bucket → *Properties* tab → scroll to *Static website hosting* → *Edit*.
   - Select **Enable**.
   - Index document: `index.html`
   - Error document: `error.html`
   - Save changes. AWS shows a **Bucket website endpoint** URL — that's your
     S3 site URL.

4. **Attach a bucket policy so objects are publicly readable**
   - Bucket → *Permissions* tab → *Bucket policy* → *Edit* → paste, replacing
     `YOUR-BUCKET-NAME`:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Sid": "PublicReadGetObject",
           "Effect": "Allow",
           "Principal": "*",
           "Action": "s3:GetObject",
           "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
         }
       ]
     }
     ```
   - Save. Open the bucket website endpoint URL from Step 3 to confirm the
     homepage loads, and that the survey link works.

Reference: [Hosting a static website on Amazon S3](http://docs.aws.amazon.com/AmazonS3/latest/dev/HostingWebsiteOnS3Setup.html)

---

## Part B — Redeploy on an Amazon EC2 web server

1. **Launch an instance**
   - EC2 Console → *Launch instance*.
   - AMI: Amazon Linux 2023 (or Ubuntu Server 22.04 — steps below cover both).
   - Instance type: `t2.micro` (free-tier eligible).
   - Key pair: create a new one, download the `.pem` file, keep it safe —
     you'll need it to SSH in.
   - Network settings: create a security group allowing:
     - SSH (port 22) from *My IP*
     - HTTP (port 80) from *Anywhere (0.0.0.0/0)*
   - Launch the instance and wait for it to reach the *Running* state.

2. **Connect to the instance**
   ```bash
   chmod 400 your-key.pem
   ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>      # Amazon Linux
   # or
   ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>        # Ubuntu
   ```

3. **Install a web server**
   - Amazon Linux:
     ```bash
     sudo yum update -y
     sudo yum install -y httpd
     sudo systemctl start httpd
     sudo systemctl enable httpd
     ```
   - Ubuntu:
     ```bash
     sudo apt update
     sudo apt install -y apache2
     sudo systemctl start apache2
     sudo systemctl enable apache2
     ```

4. **Copy the site files to the instance**
   From your local machine (in the folder containing `index.html`):
   ```bash
   scp -i your-key.pem -r index.html survey.html error.html assets \
       ec2-user@<EC2-PUBLIC-IP>:/tmp/site
   ```

5. **Move the files into the web root**
   - Amazon Linux (Apache root is `/var/www/html`):
     ```bash
     sudo cp -r /tmp/site/* /var/www/html/
     sudo systemctl restart httpd
     ```
   - Ubuntu:
     ```bash
     sudo cp -r /tmp/site/* /var/www/html/
     sudo systemctl restart apache2
     ```

6. **(Optional) Map the custom error page**
   - Add to the Apache config (e.g. `/etc/httpd/conf/httpd.conf` or a file in
     `/etc/apache2/conf-available/`):
     ```
     ErrorDocument 404 /error.html
     ```
   - Reload the service (`sudo systemctl reload httpd` / `apache2`).

7. **Verify**
   - Visit `http://<EC2-PUBLIC-IP>/` in a browser — the homepage should load,
     with the survey reachable from the nav link.

Reference: [How to Create an EC2 Instance in AWS](https://www.youtube.com/watch?v=0Gz-PUnEUF0)

---

## Notes
- Both deployments serve the exact same static files — no server-side code
  is required, so the same package works for S3 and EC2 unchanged.
- The survey form currently submits to `action="#"` since no backend is
  required by the assignment; update the `action` attribute if a real
  submission endpoint is added later.
