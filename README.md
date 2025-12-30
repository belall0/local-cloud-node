# Node.js Multi-Instance Deployment Starter

A robust, containerized Node.js application template designed for seamless multi-instance deployment with automatic SSL management.

## Overview

This repository acts as a scaffold for building and deploying scalable Node.js applications. It features a pre-configured Docker environment that utilizes **NGINX Proxy** and **ACME Companion** to handle reverse proxying and automatic Let's Encrypt SSL certificate generation. The unique deployment script allows you to spin up multiple isolated instances of the application on a single server, each mapped to its own domain.

### Features

- **Express.js Core**: Minimal web server setup with TypeScript.
- **Dockerized**: Fully containerized application for consistent environments.
- **Automatic SSL**: Zero-config HTTPS via Let's Encrypt using NGINX Proxy Companion.
- **Multi-Instance Support**: a `deploy` script that effortlessly launches parallel instances for different domains (e.g., `api.example.com`, `staging.example.com`).

---

## Prerequisites

Make sure you have the following installed on your machine:

- [Node.js](https://nodejs.org/) (v20+)
- [npm](https://www.npmjs.com/)
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)

---

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Local Installation

Install the necessary dependencies:

```bash
npm install
```

### 3. Configuration

Create a `.env` file based on the example:

```bash
cp .env.example .env
```

_Modify the `PORT` variable in `.env` if needed (default is 3000)._

### 4. Running Locally

Start the development server:

```bash
npm start
```

The server will be available at `http://localhost:3000`.

---

## Server Configuration for Local Deployment

If you are planning to deploy this on your local machine or a home server to be accessible from the internet, follow these critical networking steps:

### 1. Assign a Static IP

Ensure your machine (the server) has a **static internal IP address** (e.g., `192.168.1.100`) assigned by your router. This ensures that port forwarding rules remain valid even if the server reboots.

### 2. Configure Port Forwarding

Log in to your router's admin panel and configure **Port Forwarding** for the following ports to point to your server's static IP:

- **Port 80 (HTTP)**: Required for initial ACME challenge and HTTP traffic.
- **Port 443 (HTTPS)**: Required for secure SSL traffic.

_Note: Different routers have different interfaces for these settings. Look for "WAN", "NAT", or "Port Forwarding" menus._

---

## Deployment

The true power of this template lies in its deployment capabilities. The included `deploy.sh` script abstracts away the complexity of Docker Compose overrides.

### How to Deploy

To deploy an instance specific to a domain, simply run:

```bash
npm run deploy <your-domain>
```

**Example:**

```bash
npm run deploy api.myservice.com
```

### What happens under the hood?

1.  **Infrastructure Check**: The script first ensures that the shared `nginx-proxy` and `acme-companion` services are running. These handle incoming traffic and SSL certificates for **all** your instances.
2.  **Configuration Generation**: It dynamically generates a temporary `docker-compose` file specific to the provided domain.
3.  **Container Launch**: It builds and starts a dedicated container named after your domain (e.g., `api.myservice.com`).
4.  **Network Binding**: The new container joins the `nginx-proxy` network, allowing the proxy to route traffic to it automatically.

### Verifying Deployment

After deployment, your application will be accessible at `https://<your-domain>`.

To check running containers:

```bash
docker ps
```

---

## Architecture

The deployment architecture consists of:

1.  **NGINX Proxy**: Listens on ports 80/443 and routes traffic based on the `Host` header.
2.  **ACME Companion**: Watches for containers with `VIRTUAL_HOST` and `LETSENCRYPT_HOST` env vars and automatically handling SSL certificates.
3.  **App Instances**: One or more Node.js containers, completely isolated from each other but sharing the NGINX network.

---
