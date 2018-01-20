//
//  SMMath.h
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/1/20.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#ifndef SMMath_h
#define SMMath_h

#include <stdio.h>
#include <OpenGLES/ES3/gl.h>

#endif /* SMMath_h */

typedef struct SMMatrix4 {
    float matrix[4][4];
} SMMatrix4;

void sm_scale(SMMatrix4 *result, GLfloat sx, GLfloat sy, GLfloat sz);
void sm_translate(SMMatrix4 *result, GLfloat tx, GLfloat ty, GLfloat tz);
void sm_rotate(SMMatrix4 *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
