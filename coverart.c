#define GL_GLEXT_PROTOTYPES
#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif

const char *vertexShaderSource ="#version 330 core\n"
    "layout (location = 0) in vec3 aPos;\n"
    "layout (location = 1) in vec3 aColor;\n"
    "out vec3 ourColor;\n"
    "void main()\n"
    "{\n"
    "   gl_Position = vec4(aPos, 1.0);\n"
    "   ourColor = aColor;\n"
    "}\0";

const char *fragmentShaderSource = "#version 330 core\n"
    "out vec4 FragColor;\n"
    "in vec3 ourColor;\n"
    "void main()\n"
    "{\n"
    "   FragColor = vec4(ourColor, 1.0f);\n"
    "}\n\0"; 

void drawWall(unsigned int VAO, unsigned int VBO, unsigned int EBO, float vertices[], int size) {
    unsigned int indices[]= {
        0,1,3,
        0,2,3
    };

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    // position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    // color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
}   

void drawBrick(unsigned int VAO, unsigned int VBO, unsigned int EBO, float vertices[], int size) {
    unsigned int indices[]= {
        0,1,3,
        0,2,3
    };

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    // position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    // color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);

} 

void draw()
{
    // vertex shader
    unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);
    
    // fragment shader
    unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);
    
    // link shaders
    unsigned int shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------

    float leftWall[] = {
        // positions         // colors
        -0.99f, -0.99f, 0.0f,  0.5f, 0.5f, 0.5f,  
        -0.9f, -0.99f, 0.0f,  0.5f, 0.5f, 0.5f, 
        -0.99f, 0.99f, 0.0f,  0.5f, 0.5f, 0.5f,   
        -0.9f, 0.99f, 0.0f,  0.5f, 0.5f, 0.5f 
    };

    float rightWall[] = {
        // positions         // colors
        0.99f, -0.99f, 0.0f,  0.5f, 0.5f, 0.5f, 
        0.9f, -0.99f, 0.0f,  0.5f, 0.5f, 0.5f,
        0.99f,  0.99f, 0.0f,  0.5f, 0.5f, 0.5f, 
        0.9f,  0.99f, 0.0f,  0.5f, 0.5f, 0.5f 
    };

    float topWall[] = {
        // positions         // colors
        -0.99f, 0.99f, 0.0f,  0.5f, 0.5f, 0.5f, 
        -0.99f, 0.9f, 0.0f,  0.5f, 0.5f, 0.5f,
        0.99f,  0.99f, 0.0f,  0.5f, 0.5f, 0.5f, 
        0.99f,  0.9f, 0.0f,  0.5f, 0.5f, 0.5f 
    };
    
    unsigned int indices[]= {
        0,1,3,
        1,2,3
    };

    int i = 141; // number of rectabgles
    unsigned int VBOs[i], VAOs[i], EBO ;

    glGenVertexArrays(i, VAOs);
    glGenBuffers(i, VBOs);
    glGenBuffers(1, &EBO);

    drawWall(VAOs[0],VBOs[0],EBO,leftWall, sizeof(leftWall));
    drawWall(VAOs[1],VBOs[1],EBO,rightWall, sizeof(rightWall));
    drawWall(VAOs[2],VBOs[2],EBO,topWall, sizeof(topWall));

    for (float j = 0.0; j < 1.8; j+=0.1) {
        float brick[] = {
        // positions         // colors
        -0.9f+j, 0.8f, 0.0f,  1.0f, 0.0f, 0.0f, 
        -0.8f+j, 0.8f, 0.0f,  1.0f, 0.0f, 0.0f,
        -0.9f+j, 0.72f, 0.0f,  1.0f, 0.0f, 0.0f, 
        -0.8f+j, 0.72f, 0.0f,  1.0f, 0.0f, 0.0f
    };
    int curr = (int)10*j;
    drawBrick(VAOs[3+curr],VBOs[3+curr],EBO,brick, sizeof(brick));
    }

    for (float j = 0.0; j < 1.8; j+=0.1) {
        float brick[] = {
        // positions         // colors
        -0.9f+j, 0.72f, 0.0f,  0.0f, 0.0f, 1.0f, 
        -0.8f+j, 0.72f, 0.0f,  0.0f, 0.0f, 1.0f,
        -0.9f+j, 0.64f, 0.0f,  0.0f, 0.0f, 1.0f, 
        -0.8f+j, 0.64f, 0.0f,  0.0f, 0.0f, 1.0f
    };
    int curr = (int)10*j;
    drawBrick(VAOs[21+curr],VBOs[21+curr],EBO,brick, sizeof(brick));
    }

    for (float j = 0.0; j < 1.8; j+=0.1) {
        float brick[] = {
        // positions         // colors
        -0.9f+j, 0.64f, 0.0f,  0.5f, 1.0f, 0.5f, 
        -0.8f+j, 0.64f, 0.0f,  0.5f, 1.0f, 0.5f,
        -0.9f+j, 0.56f, 0.0f, 0.5f, 1.0f, 0.5f, 
        -0.8f+j, 0.56f, 0.0f, 0.5f, 1.0f, 0.5f
    };
    int curr = (int)10*j;
    drawBrick(VAOs[39+curr],VBOs[39+curr],EBO,brick, sizeof(brick));
    }

    for (float j = 0.0; j < 1.8; j+=0.1) {
        float brick[] = {
        // positions         // colors
        -0.9f+j, 0.56f, 0.0f,  1.0f, 0.76f, 0.75f, 
        -0.8f+j, 0.56f, 0.0f,  1.0f, 0.76f, 0.75f,
        -0.9f+j, 0.48f, 0.0f, 1.0f, 0.76f, 0.75f, 
        -0.8f+j, 0.48f, 0.0f, 1.0f, 0.76f, 0.75f
    };
    int curr = (int)10*j;
    drawBrick(VAOs[57+curr],VBOs[57+curr],EBO,brick, sizeof(brick));
    }
    
    for (float j = 0.0; j < 1.8; j+=0.1) {
        float brick[] = {
        // positions         // colors
        -0.9f+j, 0.48f, 0.0f,  0.68f, 0.85f, 0.9f, 
        -0.8f+j, 0.48f, 0.0f,  0.68f, 0.85f, 0.9f,
        -0.9f+j, 0.40f, 0.0f, 0.68f, 0.85f, 0.9f, 
        -0.8f+j, 0.40f, 0.0f, 0.68f, 0.85f, 0.9f
    };
    int curr = (int)10*j;
    drawBrick(VAOs[75+curr],VBOs[75+curr],EBO,brick, sizeof(brick));
    }

    for (float j = 0.0; j < 1.8; j+=0.1) {
        float brick[] = {
        // positions         // colors
        -0.9f+j, 0.40f, 0.0f,  0.2f, 0.49f, 0.17f, 
        -0.8f+j, 0.40f, 0.0f,  0.2f, 0.49f, 0.17f,
        -0.9f+j, 0.32f, 0.0f,   0.2f, 0.49f, 0.17f, 
        -0.8f+j, 0.32f, 0.0f,   0.2f, 0.49f, 0.17f
    };
    int curr = (int)10*j;
    drawBrick(VAOs[93+curr],VBOs[93+curr],EBO,brick, sizeof(brick));
    }
    
    int curr = 111;
    // horizantal borders
    for (float j = 0.0; j < 0.56; j+=0.08) {
        float brick[] = {
            // positions         // colors
            -0.9f, 0.805f-j, 0.0f,  0.3f, 0.31f, 0.31f, 
            0.9f, 0.805f-j, 0.0f,   0.3f, 0.31f, 0.31f,
            -0.9f, 0.795f-j, 0.0f,  0.3f, 0.31f, 0.31f, 
            0.9f, 0.795f-j, 0.0f,   0.3f, 0.31f, 0.31f
        };
        drawWall(VAOs[curr],VBOs[curr],EBO,brick, sizeof(brick));
        curr ++;
    }

    // vertical borders
     for (float j = 0.0; j < 1.9; j+=0.1) {
        float brick[] = {
            // positions         // colors
            -0.905f+j, 0.8, 0.0f,   0.3f, 0.31f, 0.31f, 
            -0.895f+j, 0.8, 0.0f,    0.3f, 0.31f, 0.31f,
            -0.905f+j, 0.32, 0.0f,   0.3f, 0.31f, 0.31f, 
            -0.895f+j, 0.32, 0.0f,    0.3f, 0.31f, 0.31f
        };
        drawWall(VAOs[curr],VBOs[curr],EBO,brick, sizeof(brick));
        curr ++;
    }


    // drawing the paddle
    float brick[] = {
        // positions         // colors
        -0.2f, -0.8, 0.0f,  0.0f, 1.0f, 0.0f, 
        0.2f, -0.8, 0.0f,  0.0f, 1.0f, 0.0f, 
        -0.2f, -0.85, 0.0f, 0.0f, 1.0f, 0.0f,  
        0.2f, -0.85, 0.0f, 0.0f, 1.0f, 0.0f, 
    };
    drawWall(VAOs[137],VBOs[137],EBO,brick, sizeof(brick));

    // drawing wall holes
    float wholeleft[] = {
        // positions         // colors
        -0.99f, -0.8, 0.0f,  0.0f, 0.0f, 0.0f, 
        -0.9f, -0.8, 0.0f,  0.0f, 0.0f, 0.0f, 
        -0.99f, -0.85, 0.0f, 0.0f, 0.0f, 0.0f,  
        -0.9f, -0.85, 0.0f, 0.0f, 0.0f, 0.0f
    };
    drawWall(VAOs[138],VBOs[138],EBO,wholeleft, sizeof(wholeleft));

    float wholeright[] = {
        // positions         // colors
        0.9f, -0.8, 0.0f,  0.0f, 0.0f, 0.0f, 
        0.99f, -0.8, 0.0f,  0.0f, 0.0f, 0.0f, 
        0.9f, -0.85, 0.0f, 0.0f, 0.0f, 0.0f,  
        0.99f, -0.85, 0.0f, 0.0f, 0.0f, 0.0f
    };
    drawWall(VAOs[139],VBOs[139],EBO,wholeright, sizeof(wholeright));

    // drawing the ball
    float ball[] = {
        // positions         // colors
        0.0f, -0.3, 0.0f,    1.0f, 1.0f, 1.0f, 
        0.01f, -0.3, 0.0f,    1.0f, 1.0f, 1.0f, 
        0.0f, -0.31, 0.0f,    1.0f, 1.0f, 1.0f,  
        0.01f, -0.31, 0.0f,    1.0f, 1.0f, 1.0f
    };
    drawWall(VAOs[140],VBOs[140],EBO,ball, sizeof(ball));

    glUseProgram(shaderProgram);


    // render everything
    for (int counter = 0; counter < 141; counter++) {
        glBindVertexArray(VAOs[counter]);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    }
    

    glutSwapBuffers();
    
}

int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE);
    glutInitWindowSize(500, 500);
    glutInitWindowPosition(100, 100);
    glutCreateWindow("Brick Breaker - 260972325");
    glutDisplayFunc(draw);
    glutMainLoop();
    return 0;
}