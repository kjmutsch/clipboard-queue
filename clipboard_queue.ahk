#Requires AutoHotkey v2.0
#SingleInstance Force


queue := []
isPasting := false

$^c::
{
    global queue

    previousClip := ClipboardAll()
    A_Clipboard := ""
    Send("^c")

    ; Wait for any clipboard data, including images
    if ClipWait(1, 1) {
        queue.Push(ClipboardAll())
        ToolTip("Queued copy. Items in queue: " queue.Length)
        SetTimer(() => ToolTip(), -700)
    } else {
        A_Clipboard := previousClip
    }
}

$^v::
{
    global queue, isPasting

    if isPasting {
        Send("^v")
        return
    }

    if queue.Length = 0 {
        Send("^v")
        return
    }

    isPasting := true
    previousClip := ClipboardAll()

    ; Restore the queued clipboard item, including image formats
    A_Clipboard := queue.RemoveAt(1)

    ; Give Windows/apps a little more time for binary clipboard formats
    Sleep(150)
    Send("^v")
    Sleep(250)

    A_Clipboard := previousClip
    isPasting := false

    ToolTip("Queue remaining: " queue.Length)
    SetTimer(() => ToolTip(), -700)
}

^+x::
{
    global queue
    queue := []
    ToolTip("Queue cleared")
    SetTimer(() => ToolTip(), -700)
}
