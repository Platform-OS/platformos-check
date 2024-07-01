# Width and height attributes on image tags (`ImgWidthAndHeight`)

This check aims to prevent [cumulative layout shift][cls] (CLS) in your platformOS application by enforcing the use of `width` and `height` attributes on `img` tags.

When `width` and `height` attributes are missing on an `img` tag, the browser doesn’t know the image’s aspect ratio until the image is fully loaded. Without this information, the browser treats the image as having a height of 0 until it loads.

This leads to several problems:

1. [Layout shift occurs as images load][codepenshift]. Text and other content get pushed down the page as the images load one after another.
2. [Lazy loading fails][codepenlazy]. When all images appear to have a height of 0px, the browser assumes they are all in the viewport and loads them immediately, defeating the purpose of lazy loading.

To fix this, ensure the `width` and `height` attributes are set on the `img` tag and that the CSS width of the image is defined.

**Note:** The `width` and `height` attributes should not include units.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
<img alt="cat" src="cat.jpg">
<img alt="cat" src="cat.jpg" width="100px" height="100px">
<img alt="{{ image.alt }}" src="{{ image.src }}">
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
<img alt="cat" src="cat.jpg" width="100" height="200">
<img
  alt="{{ image.alt }}"
  src="{{ image.src }}"
  width="{{ image.width }}"
  height="{{ image.height }}"
>
```

**NOTE:** The CSS `width` of the `img` should _also_ be set for the image to be responsive.

## Configuration Options

The default configuration for this check:

```yaml
ImgWidthAndHeight:
  enabled: true
```

## Disabling This Check - When Not To Use It

You can avoid content layout shift without `width` and `height` attributes in certain cases:

- When the aspect ratio of the displayed image should be independent of the uploaded image. In these cases, use the padding-top hack with an `overflow: hidden` container.
- When you are satisfied with the padding-top hack.

Otherwise, it’s unwise to disable this check as it can negatively impact the mobile search ranking of the merchants using your platformOS application.

## Version

This check has been introduced in platformOS Check 0.6.0.

## Resources

- [Cumulative Layout Shift Reference][cls]
- [Codepen illustrating the impact of width and height on layout shift][codepenshift]
- [Codepen illustrating the impact of width and height on lazy loading][codepenlazy]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[cls]: https://web.dev/cls/
[codepenshift]: https://codepen.io/charlespwd/pen/YzpxPEp?editors=1100
[codepenlazy]: https://codepen.io/charlespwd/pen/abZmqXJ?editors=0111
[aspect-ratio]: https://caniuse.com/mdn-css_properties_aspect-ratio
[codesource]: /lib/platformos_check/checks/img_width_and_height.rb
[docsource]: /docs/checks/img_width_and_height.md
