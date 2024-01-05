#include <iostream>

#include "commit.h"
#include "version.h"

int main(){
    std::cout << "version: " << version << std::endl;
    std::cout << "version-full: " << version_full << std::endl;
    std::cout << "commit: " << commit << std::endl;
    std::cout << "describe: " << describe << std::endl;
    std::cout << "distance: " << distance << std::endl;
    return 0;
}
