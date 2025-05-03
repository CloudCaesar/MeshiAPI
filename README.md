# Meshi Text-to-3D Salesforce Integration

This project provides a Salesforce backend integration for generating 3D models using the Meshy API. It includes Apex classes and a Lightning Web Component (LWC) to manage user data and interact with the Meshy API for text-to-3D model conversion. The solution creates a Lead, calls the Meshy API to generate a 3D model, and polls the task status to update the record.

## Features

- **Apex Classes**:
  - Integrates with the Meshy API to generate 3D models.
  - Polls Meshy task status and updates Salesforce records.
- **Lightning Web Component (LWC)**: An initial attempt to create an image-to-3D interface (not used in the final solution but included for reference).
- **Authentication**:
  - Uses a Connected App for external API access.
  - Stores the Meshy API key securely in a Custom Metadata Type.

## Prerequisites

- **Salesforce Org**: A Sales Cloud org with API access enabled.
- **Salesforce CLI**: For deploying metadata.
- **Meshy API Key**: Sign up at Meshy to get an API key.

## Setup Instructions

### 1. Clone the Salesforce Project

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name