# WaAvatarDirective Usage Examples

The `WaAvatarDirective` is an Angular wrapper for the Web Awesome `<wa-avatar>` web component. It provides a declarative way to use avatars in Angular applications with full support for Angular's binding syntax.

## Basic Usage

```html
<!-- Image avatar with accessibility label -->
<wa-avatar image="assets/avatars/user.jpg" label="User profile picture"></wa-avatar>

<!-- Initials avatar -->
<wa-avatar initials="JD" label="John Doe"></wa-avatar>
```

## Shape Options

```html
<!-- Default circle shape -->
<wa-avatar initials="JD" label="John Doe"></wa-avatar>

<!-- Square shape -->
<wa-avatar initials="JD" label="John Doe" shape="square"></wa-avatar>

<!-- Rounded shape -->
<wa-avatar initials="JD" label="John Doe" shape="rounded"></wa-avatar>
```

## Loading Options

```html
<!-- Default eager loading -->
<wa-avatar image="assets/avatars/user.jpg" label="User profile"></wa-avatar>

<!-- Lazy loading for performance -->
<wa-avatar image="assets/avatars/user.jpg" label="User profile" loading="lazy"></wa-avatar>
```

## Custom Styling

```html
<!-- Custom font size -->
<wa-avatar initials="JD" label="John Doe" [fontSize]="'var(--wa-font-size-l)'"></wa-avatar>

<!-- Custom size -->
<wa-avatar initials="JD" label="John Doe" [size]="'4rem'"></wa-avatar>

<!-- Custom colors -->
<wa-avatar 
  initials="JD" 
  label="John Doe"
  [backgroundColor]="'#e6f7ff'" 
  [textColor]="'#0050b3'">
</wa-avatar>
```

## Using CSS Variables

```html
<!-- Using style binding for CSS variables -->
<wa-avatar 
  initials="JD" 
  label="John Doe"
  [style.--size]="'3rem'"
  [style.--background-color]="'lightgray'"
  [style.--text-color]="'darkblue'">
</wa-avatar>
```

## Custom Icon

```html
<!-- Using a custom icon in the avatar -->
<wa-avatar label="Dog avatar">
  <wa-icon slot="icon" name="dog" variant="solid"></wa-icon>
</wa-avatar>
```

## Dynamic Content

```html
<wa-avatar 
  [image]="userImage" 
  [initials]="userInitials"
  [label]="userLabel"
  [shape]="avatarShape">
</wa-avatar>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaAvatarDirective]
})
export class ExampleComponent {
  userImage?: string;
  userInitials = 'JD';
  userLabel = 'John Doe';
  avatarShape: 'circle' | 'square' | 'rounded' = 'circle';
  
  loadUserImage() {
    this.userImage = 'assets/avatars/john-doe.jpg';
  }
}
```

## Integration with Angular Features

```typescript
// Component code
@Component({
  selector: 'app-example',
  template: `
    <!-- Conditional rendering -->
    <div *ngIf="showAvatar">
      <wa-avatar [image]="userImage" [label]="userLabel"></wa-avatar>
    </div>

    <!-- Rendering a list of avatars -->
    <div>
      <wa-avatar 
        *ngFor="let user of users"
        [image]="user.image"
        [initials]="user.initials"
        [label]="user.name"
        [shape]="user.avatarShape">
      </wa-avatar>
    </div>
  `,
  standalone: true,
  imports: [WaAvatarDirective, NgIf, NgFor]
})
export class ExampleComponent {
  showAvatar = true;
  userImage = 'assets/avatars/user.jpg';
  userLabel = 'User profile';
  
  users = [
    { name: 'John Doe', initials: 'JD', image: 'assets/avatars/john.jpg', avatarShape: 'circle' },
    { name: 'Jane Smith', initials: 'JS', image: 'assets/avatars/jane.jpg', avatarShape: 'square' },
    { name: 'Bob Johnson', initials: 'BJ', image: 'assets/avatars/bob.jpg', avatarShape: 'rounded' }
  ];
}
```
