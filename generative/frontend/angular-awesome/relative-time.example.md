# Relative Time Examples

## Basic Usage

```html
<wa-relative-time [ngModel]="dateValue"></wa-relative-time>
```

## Different Formats

```html
<!-- Long format (default) -->
<wa-relative-time [ngModel]="dateValue" format="long"></wa-relative-time>

<!-- Short format -->
<wa-relative-time [ngModel]="dateValue" format="short"></wa-relative-time>

<!-- Narrow format -->
<wa-relative-time [ngModel]="dateValue" format="narrow"></wa-relative-time>
```

## Numeric Options

```html
<!-- Auto (default) - uses words like "yesterday" when appropriate -->
<wa-relative-time [ngModel]="dateValue" numeric="auto"></wa-relative-time>

<!-- Always - always uses numeric values like "1 day ago" -->
<wa-relative-time [ngModel]="dateValue" numeric="always"></wa-relative-time>
```

## Language Localization

```html
<!-- English (default) -->
<wa-relative-time [ngModel]="dateValue"></wa-relative-time>

<!-- Spanish -->
<wa-relative-time [ngModel]="dateValue" lang="es"></wa-relative-time>

<!-- French -->
<wa-relative-time [ngModel]="dateValue" lang="fr"></wa-relative-time>

<!-- German -->
<wa-relative-time [ngModel]="dateValue" lang="de"></wa-relative-time>

<!-- Japanese -->
<wa-relative-time [ngModel]="dateValue" lang="ja"></wa-relative-time>
```

## Auto-Sync

```html
<!-- Without auto-sync (default) -->
<wa-relative-time [ngModel]="dateValue"></wa-relative-time>

<!-- With auto-sync enabled -->
<wa-relative-time [ngModel]="dateValue" [sync]="true"></wa-relative-time>
```

## Custom Styling

```html
<!-- Using display property -->
<wa-relative-time 
  [ngModel]="dateValue" 
  [display]="'inline-block'">
</wa-relative-time>

<!-- Using inline styles -->
<wa-relative-time 
  [ngModel]="dateValue" 
  style="color: #2196f3; font-weight: bold; font-size: 16px;">
</wa-relative-time>
```

## Using with Angular Bindings

```typescript
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-relative-time-demo',
  template: `
    <div class="controls">
      <wa-select 
        label="Format" 
        [(ngModel)]="selectedFormat">
        <wa-option value="long">Long</wa-option>
        <wa-option value="short">Short</wa-option>
        <wa-option value="narrow">Narrow</wa-option>
      </wa-select>
      
      <wa-select 
        label="Numeric" 
        [(ngModel)]="selectedNumeric">
        <wa-option value="auto">Auto</wa-option>
        <wa-option value="always">Always</wa-option>
      </wa-select>
      
      <wa-select 
        label="Language" 
        [(ngModel)]="selectedLang">
        <wa-option value="en">English</wa-option>
        <wa-option value="es">Spanish</wa-option>
        <wa-option value="fr">French</wa-option>
        <wa-option value="de">German</wa-option>
        <wa-option value="ja">Japanese</wa-option>
      </wa-select>
      
      <wa-checkbox 
        label="Auto-sync" 
        [(ngModel)]="autoSync">
      </wa-checkbox>
    </div>
    
    <div class="time-display">
      <h3>Selected Date: {{ selectedDate | date:'medium' }}</h3>
      
      <wa-relative-time 
        [ngModel]="selectedDate" 
        [format]="selectedFormat" 
        [numeric]="selectedNumeric" 
        [lang]="selectedLang" 
        [sync]="autoSync"
        (focusEvent)="onFocus()"
        (blurEvent)="onBlur()">
      </wa-relative-time>
      
      <div class="time-controls">
        <button (click)="setTimeToNow()">Now</button>
        <button (click)="setTimeToMinutesAgo(5)">5 Minutes Ago</button>
        <button (click)="setTimeToHoursAgo(1)">1 Hour Ago</button>
        <button (click)="setTimeToDaysAgo(1)">Yesterday</button>
        <button (click)="setTimeToDaysAgo(7)">Last Week</button>
        <button (click)="setTimeToMonthsAgo(1)">Last Month</button>
        <button (click)="setTimeToYearsAgo(1)">Last Year</button>
      </div>
    </div>
  `
})
export class RelativeTimeDemoComponent implements OnInit {
  selectedDate = new Date();
  selectedFormat = 'long';
  selectedNumeric = 'auto';
  selectedLang = 'en';
  autoSync = false;
  
  ngOnInit(): void {
    // Set initial date to 1 hour ago
    this.setTimeToHoursAgo(1);
  }
  
  setTimeToNow(): void {
    this.selectedDate = new Date();
  }
  
  setTimeToMinutesAgo(minutes: number): void {
    const date = new Date();
    date.setMinutes(date.getMinutes() - minutes);
    this.selectedDate = date;
  }
  
  setTimeToHoursAgo(hours: number): void {
    const date = new Date();
    date.setHours(date.getHours() - hours);
    this.selectedDate = date;
  }
  
  setTimeToDaysAgo(days: number): void {
    const date = new Date();
    date.setDate(date.getDate() - days);
    this.selectedDate = date;
  }
  
  setTimeToMonthsAgo(months: number): void {
    const date = new Date();
    date.setMonth(date.getMonth() - months);
    this.selectedDate = date;
  }
  
  setTimeToYearsAgo(years: number): void {
    const date = new Date();
    date.setFullYear(date.getFullYear() - years);
    this.selectedDate = date;
  }
  
  onFocus(): void {
    console.log('Relative time focused');
  }
  
  onBlur(): void {
    console.log('Relative time blurred');
  }
}
```

## Using with ngModel

```html
<form #timeForm="ngForm">
  <wa-input 
    type="datetime-local" 
    label="Select Date and Time" 
    [(ngModel)]="selectedDateTime" 
    name="dateTime">
  </wa-input>
  
  <div class="relative-time-display">
    <p>Selected date and time: {{ selectedDateTime | date:'medium' }}</p>
    <p>Relative time: 
      <wa-relative-time 
        [(ngModel)]="selectedDateTime" 
        name="relativeTime">
      </wa-relative-time>
    </p>
  </div>
</form>
```

## Real-World Example: Comment Timestamps

```typescript
import { Component } from '@angular/core';

interface Comment {
  id: number;
  author: string;
  content: string;
  timestamp: Date;
  likes: number;
}

@Component({
  selector: 'app-comments',
  template: `
    <div class="comments-section">
      <h2>Comments ({{ comments.length }})</h2>
      
      <div class="comment-form">
        <wa-textarea 
          label="Add a comment" 
          [(ngModel)]="newCommentText" 
          placeholder="What are your thoughts?">
        </wa-textarea>
        
        <button 
          (click)="addComment()" 
          [disabled]="!newCommentText.trim()">
          Post Comment
        </button>
      </div>
      
      <div class="comments-list">
        <div class="comment" *ngFor="let comment of comments">
          <div class="comment-header">
            <strong class="author">{{ comment.author }}</strong>
            <span class="timestamp">
              <wa-relative-time 
                [ngModel]="comment.timestamp" 
                format="short" 
                [sync]="true">
              </wa-relative-time>
            </span>
          </div>
          
          <div class="comment-content">
            {{ comment.content }}
          </div>
          
          <div class="comment-actions">
            <button class="like-button" (click)="likeComment(comment)">
              Like ({{ comment.likes }})
            </button>
            <button class="reply-button">Reply</button>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .comments-section {
      max-width: 800px;
      margin: 0 auto;
    }
    
    .comment-form {
      margin-bottom: 20px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    
    .comments-list {
      display: flex;
      flex-direction: column;
      gap: 15px;
    }
    
    .comment {
      padding: 15px;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      background-color: #f9f9f9;
    }
    
    .comment-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 10px;
    }
    
    .timestamp {
      color: #757575;
      font-size: 0.9em;
    }
    
    .comment-content {
      margin-bottom: 10px;
    }
    
    .comment-actions {
      display: flex;
      gap: 10px;
    }
  `]
})
export class CommentsComponent {
  comments: Comment[] = [
    {
      id: 1,
      author: 'Jane Doe',
      content: 'This is a great article! Thanks for sharing.',
      timestamp: new Date(Date.now() - 3600000 * 2), // 2 hours ago
      likes: 5
    },
    {
      id: 2,
      author: 'John Smith',
      content: 'I have a question about the third point you made. Could you elaborate more on that?',
      timestamp: new Date(Date.now() - 86400000), // 1 day ago
      likes: 2
    },
    {
      id: 3,
      author: 'Alice Johnson',
      content: 'I disagree with some of your conclusions, but overall a well-written piece.',
      timestamp: new Date(Date.now() - 86400000 * 3), // 3 days ago
      likes: 1
    }
  ];
  
  newCommentText = '';
  
  addComment(): void {
    if (!this.newCommentText.trim()) return;
    
    const newComment: Comment = {
      id: this.comments.length + 1,
      author: 'Current User', // In a real app, this would be the logged-in user
      content: this.newCommentText,
      timestamp: new Date(),
      likes: 0
    };
    
    this.comments.unshift(newComment);
    this.newCommentText = '';
  }
  
  likeComment(comment: Comment): void {
    comment.likes++;
  }
}
```

## Future and Past Times

```html
<!-- Past times (ago) -->
<wa-relative-time [ngModel]="pastDate"></wa-relative-time>

<!-- Future times (in) -->
<wa-relative-time [ngModel]="futureDate"></wa-relative-time>

<script>
  // In your component
  const pastDate = new Date();
  pastDate.setHours(pastDate.getHours() - 2); // 2 hours ago
  
  const futureDate = new Date();
  futureDate.setHours(futureDate.getHours() + 2); // 2 hours from now
</script>
```

## Combining with Other Components

```html
<wa-card>
  <wa-card-header>
    <h3>Event Details</h3>
  </wa-card-header>
  
  <wa-card-content>
    <div class="event-info">
      <h4>Annual Conference</h4>
      <p>Join us for our annual industry conference with speakers from around the world.</p>
      
      <div class="event-timing">
        <div class="timing-item">
          <wa-icon name="calendar"></wa-icon>
          <span>{{ eventDate | date:'fullDate' }}</span>
        </div>
        
        <div class="timing-item">
          <wa-icon name="clock"></wa-icon>
          <span>{{ eventDate | date:'shortTime' }}</span>
        </div>
        
        <div class="timing-item highlight">
          <wa-icon name="time"></wa-icon>
          <wa-relative-time 
            [ngModel]="eventDate" 
            format="long" 
            [sync]="true">
          </wa-relative-time>
        </div>
      </div>
    </div>
  </wa-card-content>
  
  <wa-card-footer>
    <wa-button>Register Now</wa-button>
  </wa-card-footer>
</wa-card>
```

## Dynamic Time Updates

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';

@Component({
  selector: 'app-countdown',
  template: `
    <div class="countdown">
      <h2>Event Countdown</h2>
      
      <div class="time-display">
        <p>Event starts: {{ eventDate | date:'medium' }}</p>
        <p class="relative-time">
          <wa-relative-time 
            [ngModel]="eventDate" 
            format="long" 
            numeric="always" 
            [sync]="true">
          </wa-relative-time>
        </p>
      </div>
      
      <div class="manual-update" *ngIf="!autoUpdate">
        <button (click)="updateTime()">Update Time</button>
        <p>Last updated: {{ lastUpdated | date:'medium' }}</p>
      </div>
      
      <wa-checkbox 
        label="Auto-update" 
        [(ngModel)]="autoUpdate">
      </wa-checkbox>
    </div>
  `
})
export class CountdownComponent implements OnInit, OnDestroy {
  eventDate = new Date();
  lastUpdated = new Date();
  autoUpdate = true;
  updateInterval: any;
  
  ngOnInit(): void {
    // Set event date to 7 days in the future
    this.eventDate = new Date();
    this.eventDate.setDate(this.eventDate.getDate() + 7);
    
    this.startAutoUpdate();
  }
  
  ngOnDestroy(): void {
    this.stopAutoUpdate();
  }
  
  startAutoUpdate(): void {
    if (this.autoUpdate) {
      this.updateInterval = setInterval(() => {
        this.updateTime();
      }, 60000); // Update every minute
    }
  }
  
  stopAutoUpdate(): void {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
    }
  }
  
  updateTime(): void {
    this.lastUpdated = new Date();
    // The relative-time component will update automatically if sync is true
  }
}
```
