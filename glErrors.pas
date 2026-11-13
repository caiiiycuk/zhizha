unit glErrors;

interface
Uses OpenGL15;

 Var LastError:String;

 Function GetLastGLError:String;

implementation

 Function GetLastGLError:String;
  Begin
   Case glGetError of
    GL_NO_ERROR          : Result:='GL_NO_ERROR';
    GL_INVALID_ENUM      : Result:='GL_INVALID_ENUM';
    GL_INVALID_VALUE     : Result:='GL_INVALID_VALUE';
    GL_INVALID_OPERATION : Result:='GL_INVALID_OPERATION';
    GL_STACK_OVERFLOW    : Result:='GL_STACK_OVERFLOW';
    GL_STACK_UNDERFLOW   : Result:='GL_STACK_UNDERFLOW';
    GL_OUT_OF_MEMORY     : Result:='GL_OUT_OF_MEMORY';
    Else Result:='GL_UNKNOW_ERROR'
   End;
   LastError:=Result;
  End;

end.
