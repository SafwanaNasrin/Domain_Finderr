import csv
import socket
import sys
from ipwhois import IPWhois
from ipwhois.exceptions import IPDefinedError

def resolve_ip(domain):
    try:
        return socket.gethostbyname(domain)
    except Exception:
        return None

def get_asn_info(ip):
    try:
        obj = IPWhois(ip)
        res = obj.lookup_rdap()
        return res.get('asn'), res.get('asn_description')
    except IPDefinedError:
        return "Private", "Private IP Space"
    except Exception:
        return None, None

def enrich_subdomains(input_csv, output_csv):
    with open(input_csv, newline='') as infile, open(output_csv, 'w', newline='') as outfile:
        reader = csv.DictReader(infile)
        fieldnames = ['subdomain', 'ip', 'asn', 'asn_description']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()

        for row in reader:
            domain = row['subdomain']
            ip = resolve_ip(domain)
            if ip:
                asn, desc = get_asn_info(ip)
            else:
                asn, desc = None, None
            writer.writerow({
                'subdomain': domain,
                'ip': ip or '',
                'asn': asn or '',
                'asn_description': desc or ''
            })

        print(f"Enriched data saved to {output_csv}")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} normalized_subdomains.csv enriched_subdomains.csv")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_csv = sys.argv[2]
    enrich_subdomains(input_csv, output_csv)
