# App Service Environment V3 (ASEv3) Module

**Path:** `modules/app-service-environments/app-service-environment.bicep`
**Scope:** `resourceGroup`
**API Version:** `Microsoft.Web/hostingEnvironments@2023-12-01`

Creates an App Service Environment V3 (ASEv3) — a single-tenant, fully isolated hosting environment for App Service apps running inside a Virtual Network.

---

## Overview

ASEv3 is the third generation of Azure App Service Environment. It runs entirely within your Virtual Network, giving you network-level isolation, predictable scaling, and support for both public (external) and internal (ILB) load balancing modes.

Key characteristics:

- Single-tenant: dedicated infrastructure, not shared with other customers
- VNet-injected: all inbound and outbound traffic flows through your VNet
- Supports Windows and Linux workloads, containers, and function apps
- App Service Plans hosted on an ASEv3 must use the `IsolatedV2` SKU tier (`I1v2`, `I2v2`, `I3v2`)
- Deployment takes approximately **2–3 hours** to provision

---

## Prerequisites

Before deploying this module, the target subnet must meet the following requirements:

1. **Empty** — no existing resources of any kind
2. **Delegated** to `Microsoft.Web/hostingEnvironments`
3. **Minimum size of `/24`** (256 addresses)

> Failure to meet any of these requirements will cause the deployment to fail or result in an unhealthy ASE.

### Configuring the Subnet Delegation

Use the subnet module from this repository to create a properly delegated subnet:

```bicep
module aseSubnet 'modules/subnets/subnet.bicep' = {
  name: 'deploy-snet-ase'
  params: {
    subnetName: 'snet-ase'
    vnetName: 'vnet-aue-dev-01'
    addressPrefix: '10.0.2.0/24'
    delegations: [
      {
        name: 'ase-delegation'
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
  }
}
```

---

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `aseName` | string | Yes | — | Name of the ASEv3 |
| `location` | string | No | `resourceGroup().location` | Azure region |
| `subnetId` | string | Yes | — | Resource ID of the dedicated, delegated subnet (min `/24`) |
| `internalLoadBalancingMode` | int | No | `0` | `0` = Public (internet-facing), `2` = Internal (ILB) |
| `zoneRedundant` | bool | No | `false` | Enable availability zone redundancy (requires 9+ workers across 3 zones) |
| `dnsSuffix` | string | No | `''` | Custom DNS suffix — uses Azure-assigned default if empty |
| `clusterSettings` | array | No | `[]` | Key-value cluster settings (e.g., `[{name: 'DisableTls1.0', value: '1'}]`) |
| `allowNewPrivateEndpointConnections` | bool | No | `false` | Allow new private endpoint connections to the ASE |
| `upgradePreference` | string | No | `'None'` | Upgrade preference: `None`, `Early`, `Late`, or `Manual` |
| `ftpEnabled` | bool | No | `false` | Enable FTP access |
| `remoteDebugEnabled` | bool | No | `false` | Enable remote debugging |
| `tags` | object | No | `{}` | Tags to apply |

### Parameter Details

#### `internalLoadBalancingMode`

Controls how the ASE exposes its apps:

| Value | Mode | Description |
|-------|------|-------------|
| `0` | `None` (Public) | Apps are reachable from the internet via a public VIP |
| `2` | `Web, Publishing` (ILB) | Apps are only reachable from within the VNet or connected networks via an internal IP |

For ILB ASEs, you must configure your own DNS to resolve the custom domain (or `dnsSuffix`) to the internal IP address.

#### `upgradePreference`

Controls when the ASE platform receives upgrades:

| Value | Description |
|-------|-------------|
| `None` | Default Azure-managed schedule |
| `Early` | Receive upgrades before the general population |
| `Late` | Receive upgrades after the general population |
| `Manual` | You control when upgrades are applied |

#### `clusterSettings`

An array of key-value objects for ASE-wide configuration. Examples:

```bicep
clusterSettings: [
  {
    name: 'DisableTls1.0'
    value: '1'
  }
  {
    name: 'InternalEncryption'
    value: 'true'
  }
]
```

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `aseId` | string | Resource ID of the ASEv3 |
| `aseName` | string | Name of the ASEv3 |
| `location` | string | Location of the ASEv3 |
| `defaultDnsSuffix` | string | DNS suffix assigned to the ASEv3 |
| `internalLoadBalancingMode` | string | Load balancing mode (`None` or `Web, Publishing`) |
| `provisioningState` | string | Current provisioning state |

---

## Usage

### Public (External) ASEv3

Apps are accessible from the internet via a public IP.

```bicep
module ase 'modules/app-service-environments/app-service-environment.bicep' = {
  name: 'deploy-ase'
  params: {
    aseName: 'ase-aue-dev-01'
    subnetId: aseSubnet.outputs.subnetId
    internalLoadBalancingMode: 0
    upgradePreference: 'None'
    tags: {
      Environment: 'dev'
      ManagedBy: 'Bicep'
    }
  }
}
```

### Internal (ILB) ASEv3

Apps are only accessible from within the VNet or connected networks. Suitable for private workloads.

```bicep
module ase 'modules/app-service-environments/app-service-environment.bicep' = {
  name: 'deploy-ase-ilb'
  params: {
    aseName: 'ase-aue-prod-01'
    subnetId: aseSubnet.outputs.subnetId
    internalLoadBalancingMode: 2
    dnsSuffix: 'internal.contoso.com'
    zoneRedundant: true
    upgradePreference: 'Manual'
    clusterSettings: [
      {
        name: 'DisableTls1.0'
        value: '1'
      }
    ]
    tags: {
      Environment: 'prod'
      ManagedBy: 'Bicep'
    }
  }
}
```

### Zone-Redundant ASEv3

Distributes workers across 3 availability zones. Requires a minimum of 9 workers (3 per zone).

```bicep
module ase 'modules/app-service-environments/app-service-environment.bicep' = {
  name: 'deploy-ase-zr'
  params: {
    aseName: 'ase-aue-prod-zr-01'
    subnetId: aseSubnet.outputs.subnetId
    internalLoadBalancingMode: 2
    zoneRedundant: true
    upgradePreference: 'Late'
    tags: {
      Environment: 'prod'
      ManagedBy: 'Bicep'
    }
  }
}
```

---

## Composing with Other Modules

### Subnet + ASEv3

```bicep
// 1. Create the delegated subnet
module aseSubnet 'modules/subnets/subnet.bicep' = {
  name: 'deploy-snet-ase'
  params: {
    subnetName: 'snet-ase'
    vnetName: 'vnet-aue-dev-01'
    addressPrefix: '10.0.2.0/24'
    delegations: [
      {
        name: 'ase-delegation'
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
  }
}

// 2. Deploy the ASEv3
module ase 'modules/app-service-environments/app-service-environment.bicep' = {
  name: 'deploy-ase'
  params: {
    aseName: 'ase-aue-dev-01'
    subnetId: aseSubnet.outputs.subnetId
    internalLoadBalancingMode: 0
    tags: {
      Environment: 'dev'
      ManagedBy: 'Bicep'
    }
  }
}
```

### Hosting Apps on an ASEv3

After the ASEv3 is deployed, create an App Service Plan with `skuTier: 'IsolatedV2'` and link it to the ASE using the `hostingEnvironmentProfile` property directly in your App Service Plan resource:

```bicep
resource aspOnAse 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'asp-aue-dev-ase-01'
  location: location
  sku: {
    name: 'I1v2'
    tier: 'IsolatedV2'
    capacity: 1
  }
  properties: {
    hostingEnvironmentProfile: {
      id: ase.outputs.aseId
    }
  }
}
```

> The `app-service-plans` module in this repository does not currently expose a `hostingEnvironmentId` parameter. Use the inline resource block above, or extend the module if ASE-hosted plans are a recurring need.

---

## NSG Considerations

If you attach a Network Security Group to the ASE subnet, it must not block traffic required by the ASE platform. ASEv3 significantly reduces the mandatory inbound rules compared to ASEv2.

**Required inbound rules:**

| Priority | Source | Destination Port | Protocol | Action | Purpose |
|----------|--------|-----------------|----------|--------|---------|
| 100 | `AppServiceManagement` | `454-455` | TCP | Allow | ASE management traffic |
| 110 | `AzureLoadBalancer` | `*` | `*` | Allow | Azure health probes |

**Required outbound rules:**

| Priority | Destination | Destination Port | Protocol | Action | Purpose |
|----------|-------------|-----------------|----------|--------|---------|
| 100 | `*` | `443` | TCP | Allow | Outbound HTTPS |
| 110 | `Sql` | `1433` | TCP | Allow | Azure SQL (ASE metadata) |
| 120 | `Storage` | `445` | TCP | Allow | Azure Storage (file shares) |

---

## Technical Notes

- **Provisioning time:** Allow 2–3 hours for initial deployment. Updates (scaling, config changes) can also take up to 1 hour.
- **Subnet immutability:** The subnet associated with an ASE **cannot be changed** after deployment. Plan your address space carefully.
- **Zone redundancy:** Once enabled, zone redundancy **cannot be disabled** without deleting and recreating the ASE.
- **ILB DNS:** For ILB ASEs, Azure does not create public DNS records. Configure private DNS zones or custom DNS servers to resolve `*.{dnsSuffix}` to the ASE's internal IP.
- **Custom domain certificates:** ILB ASEs require a wildcard or SAN certificate matching the `dnsSuffix` to be uploaded for HTTPS to function correctly.
- **Private endpoints:** `allowNewPrivateEndpointConnections: true` permits apps on the ASE to be reached via Private Endpoint from other VNets, beyond standard VNet routing.
- **FTP / Remote Debug:** Both are disabled by default. Enable only when required and ensure the NSG allows the relevant ports (21 for FTP, 4022/4024 for remote debug).

---

## Deployment

```bash
# Deploy directly (resource group must already exist)
az deployment group create \
  --resource-group rg-aue-dev-01 \
  --template-file modules/app-service-environments/app-service-environment.bicep \
  --parameters aseName=ase-aue-dev-01 subnetId=<subnet-resource-id>

# Deploy via environment entry point
az deployment group create \
  --resource-group rg-aue-dev-01 \
  --template-file environments/dev/main.bicep \
  --parameters environments/dev/main.bicepparam
```
