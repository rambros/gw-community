
# iOS Styling & UX Plan – Apple Human Interface Guidelines

This document defines generic styling and UX rules for any mobile app that should feel native on iOS and align with Apple’s Human Interface Guidelines (HIG).

---

## 1. Design Principles

The UI MUST be based on these core HIG principles: clarity, deference, depth, and consistency.

1. **Clarity**
   - Text is legible; controls are obvious and recognisable.
   - Visual hierarchy is clear: important information stands out.
   - Icons and labels are unambiguous.

2. **Deference**
   - Content comes first; chrome is minimal.
   - Use simple backgrounds, subtle separators, and lightweight decoration.
   - Avoid unnecessary visual noise or gimmicks.

3. **Depth**
   - Use layering, shadows, and motion to indicate hierarchy and focus.
   - Transitions should feel natural, helping users understand navigation and state changes.

4. **Consistency**
   - Use standard iOS patterns, terminology, and components wherever possible.
   - Similar elements behave in the same way throughout the app.

---

## 2. Layout & Structure

- Respect **safe areas**.
- Use a **single main column** layout with vertical scrolling for most content.
- Group related information into clear sections with consistent padding and spacing.
- Standard iOS spacing:
  - 16–24pt between sections.
  - 8–12pt between related elements.
- Use clear alignment:
  - Left-align labels and main text.
  - Right-align values like prices when appropriate.

---

## 3. Navigation Patterns

- **Tab bars** or **sidebars** (iPad) for top-level areas.
- **Push navigation** for drill-down flows (List → Details → Edit).
- Standard **back button** in top-left for reverse navigation.
- **Modal sheets** only for short, focused tasks.
- Avoid hidden navigation (e.g. hamburger menu) if a tab bar is suitable.

---

## 4. Typography

- Use the **system font** (SF Pro / iOS default).
- Use **Dynamic Type** text styles everywhere:
  - LargeTitle, Title, Headline, Body, Caption, etc.
- Text must scale with user accessibility settings.
- Maintain strong contrast and readability.

---

## 5. Colour & Appearance

- Use **semantic system colours**:
  - `systemBackground`, `secondarySystemBackground`
  - `label`, `secondaryLabel`, etc.
  - `systemBlue` (or user accent) for primary actions.
- Full support for **light and dark mode**.
- Use colour for meaning with text backup:
  - Green: success
  - Red: destructive or error
  - Orange/yellow: warning
- Avoid distracting background patterns or harsh gradients.

---

## 6. Controls & Components

- Prefer **native components**:
  - Buttons, lists, toggles, segmented controls, pickers.
- **Buttons**
  - Primary: filled/tinted.
  - Secondary: plain/outline.
  - Minimum target: 44×44pt.
- **Input Fields**
  - Clear labels and placeholders.
  - Inline validation messages.
- **Lists**
  - Use standard table/list cells with clear trailing icons/values.
- **Pickers**
  - Use system pickers for dates/selections.

---

## 7. Motion & Animation

- Use standard transition animations (push/pop/sheet).
- Motion reinforces hierarchy — not decoration.
- Respect system **Reduce Motion** settings:
  - Prefer fades over long sliding transitions when enabled.

---

## 8. Accessibility

- Touch targets ≥ 44×44pt.
- Support Dynamic Type in all UI text.
- VoiceOver labels must be meaningful and complete.
- Maintain strong colour contrast.
- Avoid conveying information through colour alone.

---

## 9. Platform Behaviour & Integration

- Use system **share sheet**, alerts, and menus.
- Support standard gestures (scroll, swipe-back).
- Avoid overriding built‑in gesture navigation.

---

## 10. Visual Style & Materials

- Follow Apple’s current visual language with appropriate materials.
- Subtle blur/translucency when layering (e.g. sheets).
- Maintain text legibility on blurred backgrounds.

---

## 11. Error Handling & Feedback

- Inline feedback where possible.
- System alerts only for critical decisions.
- Haptics used sparingly for key confirmations.

---

## 12. Compliance Rules

Generated UI MUST:

1. Use system font and Dynamic Type.
2. Support light and dark mode using semantic system colours.
3. Respect safe areas and iOS navigation structures.
4. Prefer native components for standard controls.
5. Use accessible sizes and labels.
6. Follow clarity, deference, depth, and consistency principles.
7. Present content professionally, minimally, and without visual noise.

---

This styling plan is reusable for any iOS‑focused mobile app.
