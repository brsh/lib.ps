<#
.SYNOPSIS
Clever trick to disable the execution policy restrictions

.DESCRIPTION
Ok this is a bit problematic ... cuz the execution policy is a security measure _intended_
to protect us from ourselves - cuz, we need it, right?

Anyhoo ... some would argue that for the most part, we _don't_ need it cuz we're smart,
responsible adults who never run code we haven't perused and investigated and that comes
from trusted sources... And it's sooo easy to disable the execution policy so why even
bother enabling it.

Me? Personally? I like having it at least set to remote-signed, and, frankly, prefer it
be restricted - specifically because it is so easy to bypass it temporarily. If I need to
run something, I can just run it via `powershell.exe -ExecutionPolicy bypass` - it's not
that hard or that many keystrokes. It just adds a little layer of security by obfuscation.

But in some cases, GPO might prevent you from temporarily adjusting the execution policy.
And that I can't stand.

So, once upon a time I came across a blog that ref'd a site that I couldn't access cuz
of a firewall security block. Well, if it's bad enough for my firewall, it's bad enough
for me. Here it is (I've made some edits to the blog's description):

(From https://blog.netspi.com/15-ways-to-bypass-the-powershell-execution-policy/)

  This function will swap out the "AuthorizationManager" with null. As a result, the
  execution policy is essentially set to bypass for the remainder of the session. This is
  temporary! It does not result in a persistent configuration change nor require writing
  to disk. (It doesn't even require PowerShell be run as an admin!!).

Note: the example borrows another trick from the blog to help run this .ps1 in the
first place :)

.EXAMPLE
some_script.ps1

Error: File some_script.ps1 cannot be loaded. It is not digitally signed....

    PS C:\>Get-Content Disable-ExecutionPolicy.ps1 | Invoke-Expression
    PS C:\>some_script.ps1
    Hello World!

.LINK
https://blog.netspi.com/15-ways-to-bypass-the-powershell-execution-policy/
#>

($ctx = $ExecutionContext.GetType().GetField("_context", "nonpublic,instance").GetValue( $executioncontext)).GetType().GetField("_authorizationManager", "nonpublic,instance").SetValue($ctx, (New-Object System.Management.Automation.AuthorizationManager "Microsoft.PowerShell"))
