+++
title = "Faster scanning of container vulnerabilities using trivy-cache"
date = "2023-01-31"
+++

Containers have become a popular method for packaging and deploying applications, but they also introduce new security challenges. One of these risks are the potential for vulnerabilities to be present in the underlying software, that is why it's essential to scan your containers regularly for known vulnerabilities.

One popular tool that can help with this task is [Trivy](https://www.aquasec.com/products/trivy/) by Aqua Security. Trivy is a lightweight, open-source vulnerability scanner specifically designed for container and Kubernetes environments.

Trivy works by analyzing the contents of your container images and comparing them to a database of known vulnerabilities. Once the scan is complete, Trivy provides a detailed report that lists any vulnerabilities that were found, their severity, and recommendations for how to resolve them.

While integrating Trivy into many of my projects, I noticed that every time the pipeline runs a scan, it has to download the database, which is both time-consuming and redundant. To address this, I've built [trivy-cache](https://gitlab.com/rahome/trivy-cache) which caches the database and reduces the need for repeated downloads.

The trivy-cache container image is rebuilt every morning, which means that it always have the latest vulnerability database. And, if you're using GitLab the project includes a template that can be included in your pipeline.

Additional information regarding usage can be found on the [trivy-cache](https://gitlab.com/rahome/trivy-cache) project page.
