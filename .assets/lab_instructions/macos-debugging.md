<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png" />&nbsp;&nbsp;Debugging Ada on Apple macOS</h1>

This is the root of the problem: macOS no longer includes the *Gnu Debugger* because the Darwin debugging back-end for *gdb* does not have complete arm64 support.
macOS has shifted to *lldb* (the LLVM debugger), but that is designed for C-Lang environments and does not completely work with Ada either.
Homebrew may be used as the source to install *gdb*, but the arm64 side does not work.
macOS on the x86_64 does support *gdb*, but that ends with macOS 27 (Golden Gate).
*gdb* is available via Homebrew, MacPorts, and included in some Alire distributions.


## *lldb* - distributed with macOS

### What genuinely works, and why

Everything that depends only on **DWARF debug info** (the language-agnostic metadata GNAT emits describing addresses,
line numbers, and type layouts) works fine, because none of it requires LLDB to *parse Ada syntax* — it just walks structured metadata:

- **Breakpoints** by file:line or function name — pure address/line lookup, no language involved.
- **Stepping** (`step`, `next`, `continue`, `finish`) — pure control-flow, language-agnostic.
- **`frame variable`** (or `fr v`) — reads a variable's current value straight from its DWARF type description,
    without going through the expression parser at all. This is the one that already worked for you and it's your main tool going forward.
- **Backtraces** (`bt`) — call stack walking, no language semantics needed.
- **Watchpoints on a named variable** (`watchpoint set variable X`) — generally works,
    since it resolves the variable's address via debug info, same mechanism as `frame variable`, not the expression evaluator.

### What's actually broken, and the underlying reason

Everything that requires LLDB to **parse and evaluate an expression** fails, because that's the step that
needs an `ada95` type system LLDB doesn't have:

- **Arithmetic/expressions**: `1 + 1`, `X + Y` — confirmed broken, what you already hit.
- **Ada attributes**: `Msg'Length`, `Msg'First`, `X'Image` — these are Ada-specific semantic constructs;
    there's no generic DWARF equivalent LLDB can fall back to.
- **Conditional breakpoints** (`break ... if X > 5`) — internally these are just expressions evaluated on every hit, so they fail the same way.
- **Calling functions from the debugger** — needs the expression evaluator to construct a call; not available.
- **Casts, slices, array indexing via typed syntax** (`Arr (3 .. 5)`) — same story.

### A specific, sharp-edged gotcha worth knowing for your Ada strings

`String` is Ada's **unconstrained array type**, represented at runtime as a fat pointer (data address + bounds), not a plain C-style buffer.
`frame variable` on a `String` may show you the raw fat-pointer structure or the underlying array bytes rather than a clean,
bounds-correct rendering the way GDB's Ada-aware pretty-printer would.

### Practical recommendation for using *lldb*

LLDB works for **"breakpoint + step + inspect," not "evaluate arbitrary expressions."**
For anything needing computed inspection (checking `Msg'Length`, testing a hypothesis mid-debug),
the workaround is: add a temporary `Put_Line` statement printing what you need,
rather than reaching for the debug console.
This is more reliable here than fighting LLDB's Ada gap.

## *gdb* - no longer distributed with macOS

### Installing *gdb*

The Gnu Debugger is still available for installation via Homebrew, MacPorts, and included in some Alire distributions.
Follow these commands (assuming Homebrew is already installed, and $ is the command prompt):

```bash
$ brew update
$ brew install gdb
$
```

*gdb* launched from VS Code on macOS arm64 or x68_64 will exit with an error code 138.
There is no viable solution for arm64.

### Signing *gdb* so macOS x86_64 lets it pass

Allowing *gdb* to run is accomplished by self-signing the package.

1. Create a self-signed certificate (one-time setup):
    <ol style="a">
        <li>Open  the <i>Keychain Access</i> application.</li>
        <li>If prompted to manage passwords instead of keychains, proceed to keychains.</i>
        <li>Select the menu <code>Keychain Access &rarr; Certificate Assistant &rarr; Create a Certificate...</code></li>
        <li>The name is your choice: something like <i>gdb-cert</i>?</li>
        <li>Set the <i>Identity Type</i> to <i>Self-Signed Root.</i></li>
        <li>Set the <i>Certificate Type</i> to <i>Code Signing.</i></li>
        <li>Check the box for <i>Let me override defaults.</i></li>
        <li>Click <i>Continue</i> on the warning dialog.</li>
        <li>Leave the <i>Certificate information</i> as it is and click <i>Continue</i>.</li>
        <li>Fill in appropriate information for the email address, common name, organization, organization unit, city,
            state (put in the full state or province name), and country or region, and then click <i>Continue.</i>:
            <img src="../images/cert-info.png" alt="cert-info" /></li>
        <li>Leave the <i>Key Pair</i> information as it is and click <i>Continue</i>.</li>
        <li>Leave the <i>Key Usage Extension</i> as it is (<i>Signature</i> should be selected) and click <i>Continue</i>.</li>
        <li>Leave the <i>Extended Key Usage Extension</i> as it is (<i>Code Signing</i> should already be selected) and click <i>Continue</i>.</li>
        <li>Leave the <i>Basic Constraints</i> as it is (unchecked) and click <i>Continue</i>.</li>
        <li>Leave the <i>Subject Alternate Name Extension</i> as it is and click <i>Continue</i>.</li>
        <li>Specify a Location for the Certificate: select <i><b>System</b></i> (very important) and click the <i>Create</i> button.</li>
        <li>Click <i>Done</i> and close the <i>Certificate Assistant</i> and the <i>Keychain Access</i> applications.</li>
        <li>Close the <i>Certificate Assistant</i> application.</li>
    </ol>

1. Enable the certificate (one-time setup):
    <ol style="a">
        <li>In the <i>Keychain Access</i> application click on the <i>System</i> group at the left.</li>
        <li>Enter <i>gdb-cert</i> in the search field at the top.</li>
        <li>Double-click the <i>gdb-cert</i> certificate to view the details.</i>
        <li>Expand the section labeled <i>Trust</i>.</i>
        <li>In the field labeled *When using this certificate* select the value *Code signing*.</li>
        <li>Exit the dialog, you will be given security prompts to confirm the change.</li>
        <li>Close the <i>Keychain Management</i> application.
    </ol>

2. Create an entitlements file, e.g. gdb-entitlement.xml:

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>com.apple.security.cs.debugger</key>
        <true/>
    </dict>
    </plist>
    ```

3. Sign your actual GDB binary. This step may need to be repeated if <i>gdb</i> is updated or reinstalled.
    It also assumes that <i>gdb</i> is in the environment PATH:

    ```bash
    $ sudo codesign --entitlements gdb-entitlement.xml -fs gdb-cert $(which gdb)
    /opt/homebrew/bin/gdb: replacing existing signature
    $ 
    ```

4. Reboot. <i>taskgated</i> is the pertinent service but restarting it is not a very reliable way to reset for the new certificate.