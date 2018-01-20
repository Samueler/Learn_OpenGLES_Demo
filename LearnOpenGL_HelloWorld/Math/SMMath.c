//
//  SMMath.c
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/1/20.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#include "SMMath.h"
#include <math.h>

void sm_scale(SMMatrix4 *result, GLfloat sx, GLfloat sy, GLfloat sz) {
    result -> matrix[0][0] *= sx;
    result -> matrix[0][1] *= sx;
    result -> matrix[0][2] *= sx;
    result -> matrix[0][3] *= sx;
    
    result -> matrix[1][0] *= sy;
    result -> matrix[1][1] *= sy;
    result -> matrix[1][2] *= sy;
    result -> matrix[1][3] *= sy;
    
    result -> matrix[2][0] *= sz;
    result -> matrix[2][1] *= sz;
    result -> matrix[2][2] *= sz;
    result -> matrix[2][3] *= sz;
}

void sm_translate(SMMatrix4 *result, GLfloat tx, GLfloat ty, GLfloat tz) {
    result -> matrix[3][0] += (result -> matrix[0][0] * tx + result -> matrix[1][0] * ty + result -> matrix[2][0] * tz);
    result -> matrix[3][1] += (result -> matrix[0][1] * tx + result -> matrix[1][1] * tx + result -> matrix[2][1] * tx);
    result -> matrix[3][2] += (result -> matrix[0][2] * tx + result -> matrix[1][2] * tx + result -> matrix[2][2] * tx);
    result -> matrix[3][3] += (result -> matrix[0][3] * tx + result -> matrix[1][3] * tx + result -> matrix[2][3] * tx);
}

void sm_rotate(SMMatrix4 *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z) {
    GLfloat sinAngle, cosAngle;
    GLfloat mag = sqrtf(x * x + y * y + z * z);
    
    sinAngle = sinf(angle * M_PI / 180.f);
    cosAngle = cosf(angle * M_PI / 180.f);
}
