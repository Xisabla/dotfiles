#parse("C File Header.h")
#parse("C File Header.h")
#pragma once
#[[#ifndef]]# ${INCLUDE_GUARD}
#[[#define]]# ${INCLUDE_GUARD}

${NAMESPACES_OPEN}

/**
 * @class ${NAME}
 * @brief Short description of the class 
 */
class ${NAME} {
  public:
    ${NAME}();
  
    // - Getters -----------------------------------------------------------------------------

    // - Setters -----------------------------------------------------------------------------

    // - Methods -----------------------------------------------------------------------------

    // - Friends -----------------------------------------------------------------------------
    
  private:
    // - Methods -----------------------------------------------------------------------------
    
    // - Attributes --------------------------------------------------------------------------
    
};

${NAMESPACES_CLOSE}

#[[#endif]]# //${INCLUDE_GUARD}
