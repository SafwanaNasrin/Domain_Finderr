import requests
import sys

def fetch_subdomains(domain):
    url = f"https://crt.sh/?q=%25.{domain}&output=json"
    try:
        response = requests.get(url, timeout=10)  # Set 10s timeout
        response.raise_for_status()               # Raise error if bad response
        data = response.json()
        subdomains = set()
        for entry in data:
            name = entry['name_value']
            # Each 'name_value' can contain multiple subdomains separated by newlines
            for sub in name.split('\n'):
                sub = sub.strip()
                if sub.endswith(domain):
                    subdomains.add(sub)
        return sorted(subdomains)
    except requests.exceptions.Timeout:
        print("Error: Request timed out. Please try again later.", file=sys.stderr)
        return []
    except Exception as e:
        print(f"Error fetching subdomains: {e}", file=sys.stderr)
        return []

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} example.com")
        sys.exit(1)
    domain = sys.argv[1]
    subs = fetch_subdomains(domain)
    for sub in subs:
        print(sub)

