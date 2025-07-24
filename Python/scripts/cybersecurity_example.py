#!/usr/bin/env python3
"""
Cybersecurity Analysis Example Script

This script demonstrates common cybersecurity tasks including network analysis,
file hashing, and basic cryptography operations.

⚠️  IMPORTANT SECURITY NOTE:
This script is for educational purposes and should only be used on networks
and systems you own or have explicit permission to test.

Usage:
    python cybersecurity_example.py

Requirements:
    - cryptography
    - requests
    - hashlib (built-in)
    - socket (built-in)
"""

import hashlib
import socket
import sys
import os
import subprocess
from datetime import datetime
from pathlib import Path
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import requests


class SecurityAnalyzer:
    """A class for performing various cybersecurity analysis tasks"""
    
    def __init__(self):
        self.results = {}
        self.start_time = datetime.now()
    
    def analyze_file_hashes(self, file_path):
        """Generate multiple hash types for a file"""
        print(f"\n🔍 Analyzing file: {file_path}")
        
        if not os.path.exists(file_path):
            print(f"❌ File not found: {file_path}")
            return None
        
        hashes_dict = {}
        
        try:
            with open(file_path, 'rb') as f:
                content = f.read()
                
                # Generate different hash types
                hashes_dict['MD5'] = hashlib.md5(content).hexdigest()
                hashes_dict['SHA1'] = hashlib.sha1(content).hexdigest()
                hashes_dict['SHA256'] = hashlib.sha256(content).hexdigest()
                hashes_dict['SHA512'] = hashlib.sha512(content).hexdigest()
                
            print("📋 File Hash Analysis:")
            for hash_type, hash_value in hashes_dict.items():
                print(f"  {hash_type}: {hash_value}")
                
            self.results['file_hashes'] = hashes_dict
            return hashes_dict
            
        except Exception as e:
            print(f"❌ Error analyzing file: {e}")
            return None
    
    def check_common_ports(self, target_host='127.0.0.1'):
        """Check common ports on a target host (localhost by default)"""
        print(f"\n🌐 Port scanning: {target_host}")
        print("⚠️  Note: Only scanning localhost for safety")
        
        # Common ports to check
        common_ports = [21, 22, 23, 25, 53, 80, 110, 143, 443, 993, 995, 8080, 8443]
        open_ports = []
        
        for port in common_ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(1)
                result = sock.connect_ex((target_host, port))
                
                if result == 0:
                    open_ports.append(port)
                    print(f"  ✅ Port {port}: OPEN")
                else:
                    print(f"  ❌ Port {port}: CLOSED")
                
                sock.close()
                
            except Exception as e:
                print(f"  ⚠️  Port {port}: ERROR - {e}")
        
        self.results['open_ports'] = open_ports
        print(f"\n📊 Summary: {len(open_ports)} open ports found")
        return open_ports
    
    def encrypt_decrypt_demo(self, message="Hello, World!"):
        """Demonstrate encryption and decryption"""
        print(f"\n🔐 Encryption/Decryption Demo")
        print(f"Original message: {message}")
        
        try:
            # Generate a key
            key = Fernet.generate_key()
            f = Fernet(key)
            
            # Encrypt the message
            encrypted_message = f.encrypt(message.encode())
            print(f"Encrypted: {encrypted_message}")
            
            # Decrypt the message
            decrypted_message = f.decrypt(encrypted_message).decode()
            print(f"Decrypted: {decrypted_message}")
            
            # Verify
            success = message == decrypted_message
            print(f"✅ Encryption/Decryption successful: {success}")
            
            self.results['encryption_test'] = {
                'original': message,
                'success': success,
                'key_length': len(key)
            }
            
            return success
            
        except Exception as e:
            print(f"❌ Encryption error: {e}")
            return False
    
    def password_strength_analyzer(self, password):
        """Analyze password strength"""
        print(f"\n🔒 Password Strength Analysis")
        
        score = 0
        feedback = []
        
        # Length check
        if len(password) >= 12:
            score += 3
            feedback.append("✅ Good length (12+ characters)")
        elif len(password) >= 8:
            score += 2
            feedback.append("⚠️  Adequate length (8+ characters)")
        else:
            score += 0
            feedback.append("❌ Password too short (less than 8 characters)")
        
        # Character variety checks
        if any(c.islower() for c in password):
            score += 1
            feedback.append("✅ Contains lowercase letters")
        else:
            feedback.append("❌ Missing lowercase letters")
        
        if any(c.isupper() for c in password):
            score += 1
            feedback.append("✅ Contains uppercase letters")
        else:
            feedback.append("❌ Missing uppercase letters")
        
        if any(c.isdigit() for c in password):
            score += 1
            feedback.append("✅ Contains numbers")
        else:
            feedback.append("❌ Missing numbers")
        
        if any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
            score += 1
            feedback.append("✅ Contains special characters")
        else:
            feedback.append("❌ Missing special characters")
        
        # Determine strength
        if score >= 6:
            strength = "STRONG"
        elif score >= 4:
            strength = "MODERATE"
        else:
            strength = "WEAK"
        
        print(f"Password strength: {strength} (Score: {score}/7)")
        for item in feedback:
            print(f"  {item}")
        
        self.results['password_analysis'] = {
            'strength': strength,
            'score': score,
            'max_score': 7
        }
        
        return strength
    
    def network_info_gathering(self):
        """Gather local network information"""
        print(f"\n🌐 Network Information Gathering")
        
        network_info = {}
        
        try:
            # Hostname
            hostname = socket.gethostname()
            network_info['hostname'] = hostname
            print(f"Hostname: {hostname}")
            
            # Local IP
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
            s.close()
            network_info['local_ip'] = local_ip
            print(f"Local IP: {local_ip}")
            
            # DNS resolution test
            try:
                dns_result = socket.gethostbyname('google.com')
                network_info['dns_working'] = True
                print(f"DNS Test (google.com): {dns_result} ✅")
            except:
                network_info['dns_working'] = False
                print("DNS Test: FAILED ❌")
            
            self.results['network_info'] = network_info
            return network_info
            
        except Exception as e:
            print(f"❌ Network info gathering error: {e}")
            return None
    
    def generate_report(self):
        """Generate a comprehensive security analysis report"""
        print("\n" + "="*60)
        print("🛡️  CYBERSECURITY ANALYSIS REPORT")
        print("="*60)
        print(f"Analysis Time: {self.start_time}")
        print(f"Duration: {datetime.now() - self.start_time}")
        
        # Summary
        print(f"\n📊 Analysis Summary:")
        if 'open_ports' in self.results:
            print(f"  • Open Ports Found: {len(self.results['open_ports'])}")
        if 'encryption_test' in self.results:
            print(f"  • Encryption Test: {'PASSED' if self.results['encryption_test']['success'] else 'FAILED'}")
        if 'password_analysis' in self.results:
            print(f"  • Password Strength: {self.results['password_analysis']['strength']}")
        
        # Save report to file
        report_dir = Path('../security-analysis')
        report_dir.mkdir(exist_ok=True)
        
        report_file = report_dir / f"security_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        
        with open(report_file, 'w') as f:
            f.write(f"Cybersecurity Analysis Report\n")
            f.write(f"Generated: {datetime.now()}\n")
            f.write(f"Results: {self.results}\n")
        
        print(f"\n📁 Report saved to: {report_file}")


def demo_file_creation():
    """Create a sample file for hash analysis"""
    sample_file = Path('../data/sample_file.txt')
    sample_file.parent.mkdir(exist_ok=True)
    
    with open(sample_file, 'w') as f:
        f.write("This is a sample file for cybersecurity analysis.\n")
        f.write("Created for educational purposes.\n")
        f.write(f"Timestamp: {datetime.now()}\n")
    
    return sample_file


def main():
    """Main execution function"""
    print("🛡️  Starting Cybersecurity Analysis Example...")
    print("⚠️  This tool is for educational purposes only!")
    print("⚠️  Only use on systems you own or have permission to test.")
    
    # Initialize analyzer
    analyzer = SecurityAnalyzer()
    
    # Create sample file and analyze
    sample_file = demo_file_creation()
    analyzer.analyze_file_hashes(sample_file)
    
    # Network analysis (localhost only for safety)
    analyzer.network_info_gathering()
    analyzer.check_common_ports('127.0.0.1')
    
    # Cryptography demo
    analyzer.encrypt_decrypt_demo("Sensitive information here!")
    
    # Password analysis
    test_passwords = [
        "password",              # Weak
        "Password123",           # Moderate
        "MyStr0ng!P@ssw0rd2024"  # Strong
    ]
    
    for pwd in test_passwords:
        print(f"\nTesting password: {'*' * len(pwd)}")
        analyzer.password_strength_analyzer(pwd)
    
    # Generate final report
    analyzer.generate_report()
    
    print("\n✅ Cybersecurity analysis complete!")
    print("💡 Tip: Check the '../security-analysis/' directory for reports")
    print("📚 Learn more about ethical hacking and cybersecurity best practices")


if __name__ == "__main__":
    main() 