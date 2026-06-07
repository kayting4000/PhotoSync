# Cross-Device Access Setup Guide

This guide explains how to access the PhotoSync application from other devices on your network.

## Prerequisites

- Both devices must be on the same network (WiFi or LAN)
- The development server must be running with the network-accessible configuration

## Starting the Development Server

### For Network-Wide Access (Recommended)

```bash
pnpm dev
```

This starts the Next.js development server on `0.0.0.0:3000`, making it accessible from other devices.

### For Localhost Only

```bash
pnpm dev:localhost
```

This starts the Next.js development server only on `localhost:3000`.

## Finding Your Local IP Address

### Windows
```powershell
ipconfig
```
Look for "IPv4 Address" under your active network connection (typically `192.168.x.x` or `10.x.x.x`).

### macOS/Linux
```bash
ifconfig
```
or
```bash
hostname -I
```

## Accessing from Other Devices

1. **Find Your Server's IP Address** (from above)
2. **From another device on the same network**, open your browser and go to:
   ```
   http://<YOUR_IP_ADDRESS>:3000
   ```

Example: `http://192.168.1.100:3000`

## Backend API Configuration

The FastAPI backend is already configured to accept connections from any host:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

The backend runs on `0.0.0.0:8000` by default, making it accessible from any network device.

**Note:** For production, you should restrict these origins to specific allowed hosts.

## Testing Cross-Device Access

### On the Client Device

1. Open a browser on the client device
2. Navigate to `http://<SERVER_IP>:3000`
3. Test the following features:
   - Login/Authentication
   - Dashboard navigation
   - Scanner functionality
   - Grade management
   - Student management

### Common Issues

| Issue | Solution |
|-------|----------|
| Cannot connect to server | Verify both devices are on the same network; check Windows Firewall allows port 3000 |
| API calls fail | Ensure the backend is running on `0.0.0.0:8000`; check API endpoint configuration in the frontend |
| CORS errors | The CORS middleware should handle this, but verify it's properly configured |

## Network Firewall Considerations

### Windows Firewall

To allow the app to be accessible on your network:

1. Press `Win + I` to open Settings
2. Go to **Privacy & Security** → **Windows Defender Firewall** → **Allow an app through firewall**
3. Click **Change settings**
4. Find **Node.js** or **node.exe** (if listed) and check both **Private** and **Public** boxes
5. If not listed, click **Allow another app** and browse for Node.js executable

Alternatively, allow port 3000:

1. Go to **Advanced settings** → **Inbound Rules**
2. Click **New Rule** → **Port** → **TCP** → Port `3000`
3. Allow the connection and apply to desired networks

## Environment Variables (if needed)

Create a `.env.local` file if you need to specify the server address:

```env
NEXT_PUBLIC_API_URL=http://<YOUR_IP_ADDRESS>:8000
```

Then update API calls to use this environment variable instead of hardcoded localhost.

## Notes

- The development server will automatically reload when you make code changes
- Mobile devices can also access the application using the same IP address and port
- For production deployment, use proper domain names and HTTPS instead of IP addresses
