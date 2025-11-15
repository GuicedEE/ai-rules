# QR Code Examples

## Basic Usage

```html
<wa-qr-code value="https://example.com"></wa-qr-code>
```

## With Label

```html
<wa-qr-code 
  value="https://example.com" 
  label="Scan me!">
</wa-qr-code>
```

## Different Sizes

```html
<wa-qr-code value="https://example.com" [size]="100"></wa-qr-code>
<wa-qr-code value="https://example.com" [size]="200"></wa-qr-code>
<wa-qr-code value="https://example.com" [size]="300"></wa-qr-code>
```

## Custom Colors

```html
<!-- Custom fill color -->
<wa-qr-code 
  value="https://example.com" 
  [fill]="'#2196f3'">
</wa-qr-code>

<!-- Custom background color -->
<wa-qr-code 
  value="https://example.com" 
  [background]="'#f5f5f5'">
</wa-qr-code>

<!-- Custom fill and background colors -->
<wa-qr-code 
  value="https://example.com" 
  [fill]="'#4caf50'" 
  [background]="'#e8f5e9'">
</wa-qr-code>
```

## Rounded Corners

```html
<wa-qr-code 
  value="https://example.com" 
  [radius]="8">
</wa-qr-code>
```

## Error Correction Levels

```html
<wa-qr-code 
  value="https://example.com" 
  errorCorrection="L">
</wa-qr-code>

<wa-qr-code 
  value="https://example.com" 
  errorCorrection="M">
</wa-qr-code>

<wa-qr-code 
  value="https://example.com" 
  errorCorrection="Q">
</wa-qr-code>

<wa-qr-code 
  value="https://example.com" 
  errorCorrection="H">
</wa-qr-code>
```

## Custom Styling with CSS Variables

```html
<!-- Using style inputs -->
<wa-qr-code 
  value="https://example.com" 
  [styleSize]="'250px'" 
  [styleFill]="'#673ab7'" 
  [styleBackground]="'#f3e5f5'" 
  [styleRadius]="'10px'">
</wa-qr-code>

<!-- Using inline styles -->
<wa-qr-code 
  value="https://example.com" 
  style="--size: 200px; --fill: #ff5722; --background: #fff3e0; --radius: 5px;">
</wa-qr-code>
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-qr-code-demo',
  template: `
    <div class="controls">
      <wa-input 
        label="QR Code Content" 
        [(ngModel)]="qrValue" 
        (input)="updateQrCode()">
      </wa-input>
      
      <wa-input 
        label="Size" 
        type="number" 
        [(ngModel)]="qrSize" 
        min="100" 
        max="500" 
        step="50">
      </wa-input>
      
      <wa-input 
        label="Fill Color" 
        type="color" 
        [(ngModel)]="qrFill">
      </wa-input>
      
      <wa-input 
        label="Background Color" 
        type="color" 
        [(ngModel)]="qrBackground">
      </wa-input>
      
      <wa-select 
        label="Error Correction" 
        [(ngModel)]="qrErrorCorrection">
        <wa-option value="L">Low (7%)</wa-option>
        <wa-option value="M">Medium (15%)</wa-option>
        <wa-option value="Q">Quartile (25%)</wa-option>
        <wa-option value="H">High (30%)</wa-option>
      </wa-select>
    </div>
    
    <div class="qr-preview">
      <wa-qr-code 
        [value]="qrValue" 
        [size]="qrSize" 
        [fill]="qrFill" 
        [background]="qrBackground" 
        [errorCorrection]="qrErrorCorrection"
        [radius]="qrRadius"
        (focusEvent)="onFocus()"
        (blurEvent)="onBlur()">
      </wa-qr-code>
    </div>
  `
})
export class QrCodeDemoComponent {
  qrValue = 'https://example.com';
  qrSize = 200;
  qrFill = '#000000';
  qrBackground = '#ffffff';
  qrErrorCorrection = 'M';
  qrRadius = 0;
  
  updateQrCode(): void {
    console.log('QR code updated with value:', this.qrValue);
  }
  
  onFocus(): void {
    console.log('QR code focused');
  }
  
  onBlur(): void {
    console.log('QR code blurred');
  }
}
```

## Using with ngModel

```html
<form #qrForm="ngForm">
  <wa-qr-code 
    [(ngModel)]="qrCodeValue" 
    name="qrCode">
  </wa-qr-code>
  
  <wa-input 
    label="QR Code Value" 
    [(ngModel)]="qrCodeValue" 
    name="qrValue">
  </wa-input>
</form>
```

## Real-World Example: Contact Information QR Code

```typescript
import { Component } from '@angular/core';

interface ContactInfo {
  name: string;
  phone: string;
  email: string;
  website: string;
  company: string;
  title: string;
}

@Component({
  selector: 'app-contact-qr',
  template: `
    <div class="contact-qr-generator">
      <h2>Contact QR Code Generator</h2>
      
      <div class="form-container">
        <form #contactForm="ngForm">
          <wa-input 
            label="Name" 
            [(ngModel)]="contact.name" 
            name="name" 
            required
            (input)="generateVCard()">
          </wa-input>
          
          <wa-input 
            label="Phone" 
            [(ngModel)]="contact.phone" 
            name="phone"
            (input)="generateVCard()">
          </wa-input>
          
          <wa-input 
            label="Email" 
            type="email" 
            [(ngModel)]="contact.email" 
            name="email"
            (input)="generateVCard()">
          </wa-input>
          
          <wa-input 
            label="Website" 
            [(ngModel)]="contact.website" 
            name="website"
            (input)="generateVCard()">
          </wa-input>
          
          <wa-input 
            label="Company" 
            [(ngModel)]="contact.company" 
            name="company"
            (input)="generateVCard()">
          </wa-input>
          
          <wa-input 
            label="Job Title" 
            [(ngModel)]="contact.title" 
            name="title"
            (input)="generateVCard()">
          </wa-input>
        </form>
      </div>
      
      <div class="qr-container">
        <wa-qr-code 
          [value]="vCardString" 
          [size]="250" 
          [fill]="'#333333'" 
          [errorCorrection]="'H'"
          label="Scan to add contact">
        </wa-qr-code>
        
        <button (click)="downloadQrCode()">Download QR Code</button>
      </div>
    </div>
  `,
  styles: [`
    .contact-qr-generator {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }
    
    .form-container {
      max-width: 500px;
    }
    
    .qr-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 15px;
    }
  `]
})
export class ContactQrComponent {
  contact: ContactInfo = {
    name: '',
    phone: '',
    email: '',
    website: '',
    company: '',
    title: ''
  };
  
  vCardString = '';
  
  ngOnInit(): void {
    this.generateVCard();
  }
  
  generateVCard(): void {
    this.vCardString = `BEGIN:VCARD
VERSION:3.0
FN:${this.contact.name}
TEL:${this.contact.phone}
EMAIL:${this.contact.email}
URL:${this.contact.website}
ORG:${this.contact.company}
TITLE:${this.contact.title}
END:VCARD`;
  }
  
  downloadQrCode(): void {
    // Implementation would use the QR code element to generate an image for download
    console.log('Downloading QR code...');
  }
}
```

## QR Code with Logo

```html
<div class="qr-with-logo">
  <wa-qr-code 
    value="https://example.com" 
    [size]="250" 
    [errorCorrection]="'H'">
    <div class="logo-container">
      <img src="assets/logo.png" alt="Logo" class="qr-logo" />
    </div>
  </wa-qr-code>
</div>

<style>
  .qr-with-logo {
    position: relative;
    display: inline-block;
  }
  
  .logo-container {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: white;
    padding: 5px;
    border-radius: 4px;
  }
  
  .qr-logo {
    width: 40px;
    height: 40px;
    object-fit: contain;
  }
</style>
```

## Dynamic QR Code Generation

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-dynamic-qr',
  template: `
    <div class="dynamic-qr">
      <div class="controls">
        <wa-select [(ngModel)]="selectedType" (change)="updateQrValue()">
          <wa-option value="url">URL</wa-option>
          <wa-option value="text">Plain Text</wa-option>
          <wa-option value="email">Email</wa-option>
          <wa-option value="sms">SMS</wa-option>
          <wa-option value="wifi">WiFi</wa-option>
        </wa-select>
        
        <ng-container [ngSwitch]="selectedType">
          <!-- URL input -->
          <wa-input 
            *ngSwitchCase="'url'" 
            label="Website URL" 
            [(ngModel)]="urlValue" 
            (input)="updateQrValue()">
          </wa-input>
          
          <!-- Text input -->
          <wa-textarea 
            *ngSwitchCase="'text'" 
            label="Text Content" 
            [(ngModel)]="textValue" 
            (input)="updateQrValue()">
          </wa-textarea>
          
          <!-- Email inputs -->
          <ng-container *ngSwitchCase="'email'">
            <wa-input 
              label="Email Address" 
              [(ngModel)]="emailAddress" 
              (input)="updateQrValue()">
            </wa-input>
            <wa-input 
              label="Subject" 
              [(ngModel)]="emailSubject" 
              (input)="updateQrValue()">
            </wa-input>
            <wa-textarea 
              label="Body" 
              [(ngModel)]="emailBody" 
              (input)="updateQrValue()">
            </wa-textarea>
          </ng-container>
          
          <!-- SMS inputs -->
          <ng-container *ngSwitchCase="'sms'">
            <wa-input 
              label="Phone Number" 
              [(ngModel)]="smsPhone" 
              (input)="updateQrValue()">
            </wa-input>
            <wa-textarea 
              label="Message" 
              [(ngModel)]="smsMessage" 
              (input)="updateQrValue()">
            </wa-textarea>
          </ng-container>
          
          <!-- WiFi inputs -->
          <ng-container *ngSwitchCase="'wifi'">
            <wa-input 
              label="Network Name (SSID)" 
              [(ngModel)]="wifiSsid" 
              (input)="updateQrValue()">
            </wa-input>
            <wa-input 
              label="Password" 
              [(ngModel)]="wifiPassword" 
              (input)="updateQrValue()">
            </wa-input>
            <wa-select 
              label="Security Type" 
              [(ngModel)]="wifiSecurity" 
              (change)="updateQrValue()">
              <wa-option value="WPA">WPA/WPA2</wa-option>
              <wa-option value="WEP">WEP</wa-option>
              <wa-option value="nopass">None</wa-option>
            </wa-select>
          </ng-container>
        </ng-container>
      </div>
      
      <div class="qr-output">
        <wa-qr-code 
          [value]="qrValue" 
          [size]="250" 
          [errorCorrection]="'M'">
        </wa-qr-code>
      </div>
    </div>
  `
})
export class DynamicQrComponent {
  selectedType = 'url';
  qrValue = '';
  
  // URL type
  urlValue = 'https://';
  
  // Text type
  textValue = '';
  
  // Email type
  emailAddress = '';
  emailSubject = '';
  emailBody = '';
  
  // SMS type
  smsPhone = '';
  smsMessage = '';
  
  // WiFi type
  wifiSsid = '';
  wifiPassword = '';
  wifiSecurity = 'WPA';
  
  ngOnInit(): void {
    this.updateQrValue();
  }
  
  updateQrValue(): void {
    switch (this.selectedType) {
      case 'url':
        this.qrValue = this.urlValue;
        break;
      case 'text':
        this.qrValue = this.textValue;
        break;
      case 'email':
        this.qrValue = `mailto:${this.emailAddress}?subject=${encodeURIComponent(this.emailSubject)}&body=${encodeURIComponent(this.emailBody)}`;
        break;
      case 'sms':
        this.qrValue = `sms:${this.smsPhone}?body=${encodeURIComponent(this.smsMessage)}`;
        break;
      case 'wifi':
        this.qrValue = `WIFI:S:${this.wifiSsid};T:${this.wifiSecurity};P:${this.wifiPassword};;`;
        break;
    }
  }
}
```
