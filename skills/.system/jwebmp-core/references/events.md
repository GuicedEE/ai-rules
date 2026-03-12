# JWebMP Core Events Reference

Complete reference of all 50+ event types in JWebMP Core.

## Mouse Events

- `OnClickAdapter` — Click event (`IOnClickService`)
- `OnDoubleClickAdapter` — Double click event (`IOnDoubleClickService`)
- `OnContextMenuAdapter` — Context menu/right-click (`IOnContextMenuService`)
- `OnMouseDownAdapter` — Mouse button pressed (`IOnMouseDownService`)
- `OnMouseUpAdapter` — Mouse button released (`IOnMouseUpService`)
- `OnMouseMoveAdapter` — Mouse moved (`IOnMouseMoveService`)
- `OnMouseEnterAdapter` — Mouse entered element (`IOnMouseEnterService`)
- `OnMouseLeaveAdapter` — Mouse left element (`IOnMouseLeaveService`)
- `OnMouseOverAdapter` — Mouse over element (`IOnMouseOverService`)
- `OnMouseOutAdapter` — Mouse out of element (`IOnMouseOutService`)
- `OnWheelAdapter` — Mouse wheel scroll (`IOnWheelService`)

## Keyboard Events

- `OnKeyDownAdapter` — Key pressed down (`IOnKeyDownService`)
- `OnKeyUpAdapter` — Key released (`IOnKeyUpService`)
- `OnKeyPressAdapter` — Key pressed (deprecated, use keydown) (`IOnKeyPressService`)

## Form Events

- `OnChangeAdapter` — Input value changed (`IOnChangeService`)
- `OnInputAdapter` — Input value changing (`IOnInputService`)
- `OnSubmitAdapter` — Form submitted (`IOnSubmitService`)
- `OnResetAdapter` — Form reset (`IOnResetService`)
- `OnFocusAdapter` — Element focused (`IOnFocusService`)
- `OnBlurAdapter` — Element lost focus (`IOnBlurService`)
- `OnFocusInAdapter` — Focus in (bubbles) (`IOnFocusInService`)
- `OnFocusOutAdapter` — Focus out (bubbles) (`IOnFocusOutService`)
- `OnSelectAdapter` — Text selected (`IOnSelectService`)

## Drag & Drop Events

- `OnDragAdapter` — Element being dragged (`IOnDragService`)
- `OnDragStartAdapter` — Drag started (`IOnDragStartService`)
- `OnDragEndAdapter` — Drag ended (`IOnDragEndService`)
- `OnDragEnterAdapter` — Dragged item entered drop zone (`IOnDragEnterService`)
- `OnDragLeaveAdapter` — Dragged item left drop zone (`IOnDragLeaveService`)
- `OnDragOverAdapter` — Dragged over drop zone (`IOnDragOverService`)
- `OnDropAdapter` — Item dropped (`IOnDropService`)

## Touch Events

- `OnTouchStartAdapter` — Touch started (`IOnTouchStartService`)
- `OnTouchEndAdapter` — Touch ended (`IOnTouchEndService`)
- `OnTouchMoveAdapter` — Touch moved (`IOnTouchMoveService`)
- `OnTouchCancelAdapter` — Touch cancelled (`IOnTouchCancelService`)

## Clipboard Events

- `OnCopyAdapter` — Content copied (`IOnCopyService`)
- `OnCutAdapter` — Content cut (`IOnCutService`)
- `OnPasteAdapter` — Content pasted (`IOnPasteService`)

## Media Events

- `OnPlayAdapter` — Media started playing (`IOnPlayService`)
- `OnPauseAdapter` — Media paused (`IOnPauseService`)
- `OnEndedAdapter` — Media ended (`IOnEndedService`)
- `OnVolumeChangeAdapter` — Volume changed (`IOnVolumeChangeService`)
- `OnTimeUpdateAdapter` — Playback time updated (`IOnTimeUpdateService`)
- `OnLoadedDataAdapter` — Media data loaded (`IOnLoadedDataService`)
- `OnLoadedMetaDataAdapter` — Media metadata loaded (`IOnLoadedMetaDataService`)
- `OnCanPlayAdapter` — Media can start playing (`IOnCanPlayService`)
- `OnCanPlayThroughAdapter` — Media can play through (`IOnCanPlayThroughService`)

## Animation & Transition Events

- `OnAnimationStartAdapter` — CSS animation started (`IOnAnimationStartService`)
- `OnAnimationEndAdapter` — CSS animation ended (`IOnAnimationEndService`)
- `OnAnimationIterationAdapter` — CSS animation repeated (`IOnAnimationIterationService`)
- `OnTransitionEndAdapter` — CSS transition ended (`IOnTransitionEndService`)

## Window & Document Events

- `OnLoadAdapter` — Resource loaded (`IOnLoadService`)
- `OnUnloadAdapter` — Page unloading (`IOnUnloadService`)
- `OnBeforeUnloadAdapter` — Before page unload (`IOnBeforeUnloadService`)
- `OnResizeAdapter` — Window resized (`IOnResizeService`)
- `OnScrollAdapter` — Element scrolled (`IOnScrollService`)

## Error Events

- `OnErrorAdapter` — Error occurred (`IOnErrorService`)
- `OnAbortAdapter` — Loading aborted (`IOnAbortService`)

## Event Usage Pattern

All events **must be named classes** (no lambdas or anonymous inner classes):

```java
public class MyClickEvent extends OnClickAdapter {
    public MyClickEvent(Component component) {
        super(component);
    }

    @Override
    public void onClick(AjaxCall<?> call, AjaxResponse<?> response) {
        // Handle click
    }
}

// Attach to component
component.addEvent(new MyClickEvent(component));
```

## Event Registration (module-info.java)

```java
provides IOnClickService with MyClickEvent;
provides IOnChangeService with MyChangeEvent;
// etc.
```
