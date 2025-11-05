# Format Number Examples

## Basic Usage

```html
<wa-format-number [value]="1234.56"></wa-format-number>
```

## With Two-Way Binding

```html
<wa-format-number [(ngModel)]="amount"></wa-format-number>
```

```typescript
// In your component
export class FormatNumberExampleComponent {
  amount = 1234.56;
}
```

## Different Formatting Types

```html
<!-- Default is 'decimal' -->
<wa-format-number [value]="1234.56"></wa-format-number>

<!-- Currency format -->
<wa-format-number [value]="1234.56" type="currency" currency="USD"></wa-format-number>

<!-- Percentage format -->
<wa-format-number [value]="0.75" type="percent"></wa-format-number>
```

## Currency Options

```html
<!-- Default currency symbol -->
<wa-format-number [value]="1234.56" type="currency" currency="USD"></wa-format-number>

<!-- Currency code -->
<wa-format-number [value]="1234.56" type="currency" currency="USD" currencyDisplay="code"></wa-format-number>

<!-- Currency name -->
<wa-format-number [value]="1234.56" type="currency" currency="USD" currencyDisplay="name"></wa-format-number>

<!-- Different currencies -->
<wa-format-number [value]="1234.56" type="currency" currency="EUR"></wa-format-number>
<wa-format-number [value]="1234.56" type="currency" currency="GBP"></wa-format-number>
<wa-format-number [value]="1234.56" type="currency" currency="JPY"></wa-format-number>
```

## Fraction Digits Control

```html
<!-- Minimum 2 fraction digits -->
<wa-format-number [value]="1234.5" [minimumFractionDigits]="2"></wa-format-number>

<!-- Maximum 2 fraction digits -->
<wa-format-number [value]="1234.567" [maximumFractionDigits]="2"></wa-format-number>

<!-- Fixed 2 fraction digits -->
<wa-format-number 
  [value]="1234.5" 
  [minimumFractionDigits]="2" 
  [maximumFractionDigits]="2">
</wa-format-number>
```

## Integer Digits Control

```html
<!-- Minimum 5 integer digits (e.g., 01,234.56) -->
<wa-format-number [value]="1234.56" [minimumIntegerDigits]="5"></wa-format-number>
```

## Significant Digits Control

```html
<!-- Minimum 3 significant digits -->
<wa-format-number [value]="1.2" [minimumSignificantDigits]="3"></wa-format-number>

<!-- Maximum 3 significant digits -->
<wa-format-number [value]="1234.56" [maximumSignificantDigits]="3"></wa-format-number>

<!-- Between 2 and 4 significant digits -->
<wa-format-number 
  [value]="1234.56" 
  [minimumSignificantDigits]="2" 
  [maximumSignificantDigits]="4">
</wa-format-number>
```

## Grouping Control

```html
<!-- With grouping (default) -->
<wa-format-number [value]="1234567.89"></wa-format-number>

<!-- Without grouping -->
<wa-format-number [value]="1234567.89" [noGrouping]="true"></wa-format-number>
```

## Localization

```html
<!-- Default uses browser locale -->
<wa-format-number [value]="1234.56" type="currency" currency="USD"></wa-format-number>

<!-- German locale -->
<wa-format-number [value]="1234.56" type="currency" currency="EUR" lang="de"></wa-format-number>

<!-- French locale -->
<wa-format-number [value]="1234.56" type="currency" currency="EUR" lang="fr"></wa-format-number>

<!-- Japanese locale -->
<wa-format-number [value]="1234.56" type="currency" currency="JPY" lang="ja"></wa-format-number>
```

## Styling Examples

```html
<!-- Custom color -->
<wa-format-number 
  [value]="1234.56" 
  type="currency" 
  currency="USD" 
  color="#3f51b5">
</wa-format-number>

<!-- Custom font size -->
<wa-format-number 
  [value]="1234.56" 
  type="currency" 
  currency="USD" 
  fontSize="1.5rem">
</wa-format-number>

<!-- Bold text -->
<wa-format-number 
  [value]="1234.56" 
  type="currency" 
  currency="USD" 
  fontWeight="bold">
</wa-format-number>

<!-- Right-aligned text -->
<wa-format-number 
  [value]="1234.56" 
  type="currency" 
  currency="USD" 
  textAlign="right">
</wa-format-number>

<!-- Inline display -->
<p>
  The total is 
  <wa-format-number 
    [value]="1234.56" 
    type="currency" 
    currency="USD" 
    display="inline">
  </wa-format-number>
  including tax.
</p>
```

## In a Form

```html
<form>
  <div class="form-group">
    <label for="amount">Amount:</label>
    <input 
      type="number" 
      id="amount" 
      [(ngModel)]="amount" 
      name="amount"
      step="0.01">
  </div>
  
  <div class="form-group">
    <label>Formatted Amount:</label>
    <wa-format-number 
      [value]="amount"
      type="currency"
      currency="USD">
    </wa-format-number>
  </div>
</form>
```

## In a Table

```html
<!-- Example of using format-number in a table -->
<table>
  <thead>
    <tr>
      <th>Product</th>
      <th>Price</th>
      <th>Quantity</th>
      <th>Total</th>
    </tr>
  </thead>
  <tbody>
    <!-- Using ngFor to iterate through products -->
    <tr *ngFor="let product of products">
      <td>{{ product.name }}</td>
      <td>
        <wa-format-number 
          [value]="product.price"
          type="currency"
          currency="USD">
        </wa-format-number>
      </td>
      <td>{{ product.quantity }}</td>
      <td>
        <wa-format-number 
          [value]="product.price * product.quantity"
          type="currency"
          currency="USD">
        </wa-format-number>
      </td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="3">Total</td>
      <td>
        <wa-format-number 
          [value]="calculateTotal()"
          type="currency"
          currency="USD"
          fontWeight="bold">
        </wa-format-number>
      </td>
    </tr>
  </tfoot>
</table>
```

```typescript
// In your component
export class FormatNumberExampleComponent {
  products = [
    { name: 'Product A', price: 19.99, quantity: 2 },
    { name: 'Product B', price: 29.99, quantity: 1 },
    { name: 'Product C', price: 9.99, quantity: 3 }
  ];
  
  calculateTotal(): number {
    return this.products.reduce((sum, product) => sum + (product.price * product.quantity), 0);
  }
}
```

## With Dynamic Values

```html
<div>
  <input 
    type="range" 
    [(ngModel)]="value" 
    min="0" 
    max="1000" 
    step="10">
  
  <p>
    Raw value: {{ value }}
  </p>
  
  <p>
    Decimal: <wa-format-number [value]="value"></wa-format-number>
  </p>
  
  <p>
    Currency: <wa-format-number [value]="value" type="currency" currency="USD"></wa-format-number>
  </p>
  
  <p>
    Percentage: <wa-format-number [value]="value / 1000" type="percent"></wa-format-number>
  </p>
</div>
```

## Conditional Formatting

```html
<!-- Format based on value -->
<div *ngFor="let transaction of transactions">
  <span>{{ transaction.description }}</span>
  <wa-format-number 
    [value]="transaction.amount"
    type="currency"
    currency="USD"
    [color]="transaction.amount >= 0 ? 'green' : 'red'">
  </wa-format-number>
</div>
```

```typescript
// In your component
export class FormatNumberExampleComponent {
  transactions = [
    { description: 'Deposit', amount: 500 },
    { description: 'Withdrawal', amount: -200 },
    { description: 'Interest', amount: 5.25 },
    { description: 'Fee', amount: -15 }
  ];
}
```

## Budget Progress Example

```html
<div class="budget-item" *ngFor="let category of budget">
  <div class="category-name">{{ category.name }}</div>
  <div class="amounts">
    <div class="spent">
      Spent: 
      <wa-format-number 
        [value]="category.spent"
        type="currency"
        currency="USD">
      </wa-format-number>
    </div>
    <div class="budget">
      Budget: 
      <wa-format-number 
        [value]="category.budget"
        type="currency"
        currency="USD">
      </wa-format-number>
    </div>
  </div>
  <div class="percentage">
    <wa-format-number 
      [value]="category.spent / category.budget"
      type="percent"
      [maximumFractionDigits]="0">
    </wa-format-number>
  </div>
</div>
```

```typescript
// In your component
export class FormatNumberExampleComponent {
  budget = [
    { name: 'Housing', spent: 1200, budget: 1500 },
    { name: 'Food', spent: 450, budget: 500 },
    { name: 'Transportation', spent: 350, budget: 300 },
    { name: 'Entertainment', spent: 120, budget: 200 }
  ];
}
```
