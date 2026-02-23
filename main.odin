package Normals

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:bufio"
import "core:strconv"
import "core:os"
import "core:math"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

main :: proc() {
    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_CORE_PROFILE, glfw.OPENGL_CORE_PROFILE)

    if !glfw.Init() {fmt.println("Window did not init :("); return}
    defer glfw.Terminate();

    window := glfw.CreateWindow(500, 500, "Normal map picker", nil, nil)
    if window == nil {fmt.println("Window not created :("); return}
    defer glfw.DestroyWindow(window)

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)

    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    gl.Disable(gl.DEPTH_TEST)
    gl.Disable(gl.CULL_FACE)

    shader, ok := gl.load_shaders_file("shader.vs", "normal.fs")
    if !ok {panic("Failed to compile shader")}

    //shader2, ok2 := gl.load_shaders_file("shader.vs", "normal.fs")
    //if !ok2 {panic("Failed to compile shader")}

    boxVerts: []f32 = {
        -1, -1,
        1, -1,
        -1, 1,
        1, 1
    }

    boxVAO, boxVBO: u32
    gl.GenVertexArrays(1, &boxVAO)
    gl.GenBuffers(1, &boxVBO)

    gl.BindVertexArray(boxVAO)
    gl.BindBuffer(gl.ARRAY_BUFFER, boxVBO)
    gl.BufferData(gl.ARRAY_BUFFER, 32, &boxVerts[0], gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 8, 0)
    gl.EnableVertexAttribArray(0)

    gl.BindVertexArray(0)

    mode := 0
    numSlices := 16
    numCircles := 4

    s: bufio.Scanner
    bufio.scanner_init(&s, os.stream_from_handle(os.stdin), context.temp_allocator)


    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()

        gl.ClearColor(0,0,0,0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(shader)
        gl.BindVertexArray(boxVAO)
        gl.DrawArrays(gl.TRIANGLE_STRIP, 0, 4)

        glfw.SwapBuffers(window)

        fmt.print("Horizontal angle (degrees): ")
        if !bufio.scanner_scan(&s) {break}
        line := bufio.scanner_text(&s)
        a, ok := strconv.parse_f64(line)
        a *= math.PI / 180

        fmt.print("Vertical angle (degrees): ")
        if !bufio.scanner_scan(&s) {break}
        line = bufio.scanner_text(&s)
        b, ok2 := strconv.parse_f64(line)
        b *= math.PI / 180

        r, g, b2: f64 = math.cos(b) * math.cos(a), math.cos(b) * math.sin(a), math.sin(b)
        fmt.printfln("RGB: 0x%02x%02x%02x", i32(math.round(r * 127.5 + 127.5)), i32(math.round(g * 127.5 + 127.5)), i32(math.round(b2 * 255)))

    }
}