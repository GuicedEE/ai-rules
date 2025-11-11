# Tree Examples

## Basic Usage

```html
<wa-tree>
  <wa-tree-item>
    Root Item
    <wa-tree-item>Child Item 1</wa-tree-item>
    <wa-tree-item>Child Item 2</wa-tree-item>
  </wa-tree-item>
  <wa-tree-item>
    Another Root Item
    <wa-tree-item>Child Item 3</wa-tree-item>
    <wa-tree-item>Child Item 4</wa-tree-item>
  </wa-tree-item>
</wa-tree>
```

## Selection Modes

```html
<!-- Single selection mode -->
<wa-tree selection="single">
  <wa-tree-item>
    Root Item 1
    <wa-tree-item>Child Item 1.1</wa-tree-item>
    <wa-tree-item>Child Item 1.2</wa-tree-item>
  </wa-tree-item>
  <wa-tree-item>
    Root Item 2
    <wa-tree-item>Child Item 2.1</wa-tree-item>
    <wa-tree-item>Child Item 2.2</wa-tree-item>
  </wa-tree-item>
</wa-tree>

<!-- Multiple selection mode -->
<wa-tree selection="multiple">
  <wa-tree-item>
    Root Item 1
    <wa-tree-item>Child Item 1.1</wa-tree-item>
    <wa-tree-item>Child Item 1.2</wa-tree-item>
  </wa-tree-item>
  <wa-tree-item>
    Root Item 2
    <wa-tree-item>Child Item 2.1</wa-tree-item>
    <wa-tree-item>Child Item 2.2</wa-tree-item>
  </wa-tree-item>
</wa-tree>

<!-- Leaf selection mode (only leaf nodes can be selected) -->
<wa-tree selection="leaf">
  <wa-tree-item>
    Root Item 1
    <wa-tree-item>Child Item 1.1</wa-tree-item>
    <wa-tree-item>Child Item 1.2</wa-tree-item>
  </wa-tree-item>
  <wa-tree-item>
    Root Item 2
    <wa-tree-item>Child Item 2.1</wa-tree-item>
    <wa-tree-item>Child Item 2.2</wa-tree-item>
  </wa-tree-item>
</wa-tree>
```

## Expanded and Selected States

```html
<wa-tree>
  <wa-tree-item [expanded]="true">
    Expanded Root Item
    <wa-tree-item>Child Item 1</wa-tree-item>
    <wa-tree-item>Child Item 2</wa-tree-item>
  </wa-tree-item>
  <wa-tree-item [selected]="true">
    Selected Root Item
    <wa-tree-item>Child Item 3</wa-tree-item>
    <wa-tree-item>Child Item 4</wa-tree-item>
  </wa-tree-item>
  <wa-tree-item [expanded]="true" [selected]="true">
    Expanded and Selected Root Item
    <wa-tree-item>Child Item 5</wa-tree-item>
    <wa-tree-item>Child Item 6</wa-tree-item>
  </wa-tree-item>
</wa-tree>
```

## Disabled Items

```html
<wa-tree>
  <wa-tree-item>
    Root Item 1
    <wa-tree-item>Child Item 1.1</wa-tree-item>
    <wa-tree-item [disabled]="true">Disabled Child Item 1.2</wa-tree-item>
  </wa-tree-item>
  <wa-tree-item [disabled]="true">
    Disabled Root Item 2
    <wa-tree-item>Child Item 2.1</wa-tree-item>
    <wa-tree-item>Child Item 2.2</wa-tree-item>
  </wa-tree-item>
</wa-tree>
```

## Lazy Loading

```typescript
import { Component } from '@angular/core';
import { WaTreeDirective, WaTreeItemDirective } from '@angular-awesome/directives/tree';

@Component({
  selector: 'app-lazy-tree-demo',
  template: `
    <wa-tree>
      <wa-tree-item [expanded]="true">
        Root Item
        <wa-tree-item>Child Item 1</wa-tree-item>
        <wa-tree-item [lazy]="true" (lazyLoad)="loadChildren($event)">
          Lazy Loaded Children
        </wa-tree-item>
      </wa-tree-item>
    </wa-tree>
  `,
  standalone: true,
  imports: [WaTreeDirective, WaTreeItemDirective]
})
export class LazyTreeDemoComponent {
  loadChildren(event: Event) {
    // Simulate loading data from a server
    setTimeout(() => {
      const target = event.target as HTMLElement;

      // Create new tree items
      const child1 = document.createElement('wa-tree-item');
      child1.textContent = 'Lazy Loaded Child 1';

      const child2 = document.createElement('wa-tree-item');
      child2.textContent = 'Lazy Loaded Child 2';

      // Append to the lazy tree item
      target.appendChild(child1);
      target.appendChild(child2);
    }, 1000);
  }
}
```

## Custom Styling

```html
<!-- Custom indent size and guide style -->
<wa-tree [indentSize]="'32px'" [indentGuideStyle]="'dotted'">
  <wa-tree-item [expanded]="true">
    Root Item with Custom Indent
    <wa-tree-item>Child Item 1</wa-tree-item>
    <wa-tree-item>Child Item 2</wa-tree-item>
  </wa-tree-item>
</wa-tree>

<!-- Custom indent guide color and width -->
<wa-tree [indentGuideColor]="'#2196F3'" [indentGuideWidth]="'2px'">
  <wa-tree-item [expanded]="true">
    Root Item with Custom Guide
    <wa-tree-item>Child Item 1</wa-tree-item>
    <wa-tree-item>Child Item 2</wa-tree-item>
  </wa-tree-item>
</wa-tree>

<!-- Custom tree item styling -->
<wa-tree>
  <wa-tree-item 
    [expanded]="true"
    [selectionBackgroundColor]="'#e3f2fd'"
    [selectionIndicatorColor]="'#2196F3'"
    [expandButtonColor]="'#1976d2'"
  >
    Root Item with Custom Colors
    <wa-tree-item>Child Item 1</wa-tree-item>
    <wa-tree-item>Child Item 2</wa-tree-item>
  </wa-tree-item>
</wa-tree>

<!-- Custom animation durations -->
<wa-tree>
  <wa-tree-item 
    [showDuration]="'500ms'"
    [hideDuration]="'300ms'"
  >
    Root Item with Custom Animation
    <wa-tree-item>Child Item 1</wa-tree-item>
    <wa-tree-item>Child Item 2</wa-tree-item>
  </wa-tree-item>
</wa-tree>
```

## Event Handling

```typescript
import { Component } from '@angular/core';
import { WaTreeDirective, WaTreeItemDirective } from '@angular-awesome/directives/tree';

@Component({
  selector: 'app-tree-events-demo',
  template: `
    <wa-tree (selectionChange)="onSelectionChange($event)">
      <wa-tree-item
        (expand)="onExpand($event)"
        (afterExpand)="onAfterExpand($event)"
        (collapse)="onCollapse($event)"
        (afterCollapse)="onAfterCollapse($event)"
      >
        Root Item with Event Handlers
        <wa-tree-item>Child Item 1</wa-tree-item>
        <wa-tree-item>Child Item 2</wa-tree-item>
      </wa-tree-item>
    </wa-tree>

    <div class="event-log">
      <p>Last event: {{ lastEvent }}</p>
    </div>
  `,
  standalone: true,
  imports: [WaTreeDirective, WaTreeItemDirective]
})
export class TreeEventsDemoComponent {
  lastEvent = 'None';

  onSelectionChange(event: any) {
    this.lastEvent = 'Selection changed';
    console.log('Selection changed:', event);
  }

  onExpand(event: Event) {
    this.lastEvent = 'Item expanding';
    console.log('Item expanding:', event);
  }

  onAfterExpand(event: Event) {
    this.lastEvent = 'Item expanded';
    console.log('Item expanded:', event);
  }

  onCollapse(event: Event) {
    this.lastEvent = 'Item collapsing';
    console.log('Item collapsing:', event);
  }

  onAfterCollapse(event: Event) {
    this.lastEvent = 'Item collapsed';
    console.log('Item collapsed:', event);
  }
}
```

## Dynamic Tree

```typescript
import { Component } from '@angular/core';
import { WaTreeDirective, WaTreeItemDirective } from '@angular-awesome/directives/tree';
import { NgFor } from '@angular/common';

interface TreeNode {
  id: string;
  name: string;
  children?: TreeNode[];
  expanded?: boolean;
}

@Component({
  selector: 'app-dynamic-tree-demo',
  template: `
    <div class="controls">
      <button (click)="addNode()">Add Node</button>
      <button (click)="removeNode()" [disabled]="!canRemoveNode()">Remove Last Node</button>
    </div>

    <wa-tree selection="multiple" (selectionChange)="onSelectionChange($event)">
      <ng-container *ngFor="let node of treeData">
        <wa-tree-item [expanded]="node.expanded">
          {{ node.name }}
          <ng-container *ngFor="let child of node.children">
            <wa-tree-item>
              {{ child.name }}
            </wa-tree-item>
          </ng-container>
        </wa-tree-item>
      </ng-container>
    </wa-tree>

    <div class="selection-info">
      <p>Selected nodes: {{ selectedNodes.join(', ') || 'None' }}</p>
    </div>
  `,
  standalone: true,
  imports: [WaTreeDirective, WaTreeItemDirective, NgFor]
})
export class DynamicTreeDemoComponent {
  treeData: TreeNode[] = [
    {
      id: 'node1',
      name: 'Node 1',
      expanded: true,
      children: [
        { id: 'node1-1', name: 'Node 1.1' },
        { id: 'node1-2', name: 'Node 1.2' }
      ]
    },
    {
      id: 'node2',
      name: 'Node 2',
      children: [
        { id: 'node2-1', name: 'Node 2.1' }
      ]
    }
  ];

  selectedNodes: string[] = [];

  addNode() {
    const newNodeId = `node${this.treeData.length + 1}`;
    this.treeData.push({
      id: newNodeId,
      name: `Node ${this.treeData.length + 1}`,
      children: [
        { id: `${newNodeId}-1`, name: `Node ${this.treeData.length + 1}.1` }
      ]
    });
  }

  removeNode() {
    if (this.canRemoveNode()) {
      this.treeData.pop();
    }
  }

  canRemoveNode(): boolean {
    return this.treeData.length > 1;
  }

  onSelectionChange(event: any) {
    // In a real application, you would extract the selected node IDs from the event
    // This is a simplified example
    this.selectedNodes = event.detail.map((node: any) => node.id);
  }
}
```

## Custom Icons

```html
<wa-tree>
  <wa-tree-item>
    <span slot="expand-icon">📂</span>
    <span slot="collapse-icon">📁</span>
    Folder with Custom Icons
    <wa-tree-item>
      <wa-icon name="document"></wa-icon> Document 1
    </wa-tree-item>
    <wa-tree-item>
      <wa-icon name="document"></wa-icon> Document 2
    </wa-tree-item>
  </wa-tree-item>
</wa-tree>
```
