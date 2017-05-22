//
//  main.m
//  UsingLibClang
//
//  Created by Dan.Lee on 2017/5/22.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <cstdio>
#include <string>
#include <cstdlib>
#include "clang-c/Index.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CXTranslationUnit tu;
        CXIndex index = clang_createIndex(1, 1);
        const char *filePath = "/Users/ios/NO2/iPhoneLoan/WMPayDayLoan/Modules/HomeModule/ViewController/PDLHomeViewController.m";
        tu = clang_parseTranslationUnit(index, filePath, NULL, 0, nullptr, 0, CXTranslationUnit_Incomplete);
        if (!tu) {
            printf("Couldn't create translation unit");
            return 1;
        }
        
        CXCursor rootCursor = clang_getTranslationUnitCursor(tu);
        CXToken *tokens;
        unsigned int numTokens;
        CXCursor *cursors = 0;
        CXSourceRange range = clang_getCursorExtent(rootCursor);
        clang_tokenize(tu, range, &tokens, &numTokens);
        cursors = (CXCursor *)malloc(numTokens * sizeof(CXCursor));
        clang_annotateTokens(tu, tokens, numTokens, cursors);
        
        for(int i=0; i < numTokens; i++) {
            CXToken token = tokens[i];
            CXCursor cursor = cursors[i];
            CXString tokenSpelling = clang_getTokenSpelling(tu, token);
            CXString cursorSpelling = clang_getCursorSpelling(cursor);
            const char *tokenName = clang_getCString(tokenSpelling);
            if (CXToken_Literal == clang_getTokenKind(token)
                && CXCursor_PreprocessingDirective != cursor.kind
                && strlen(tokenName) >= 2
                && tokenName[0] == '\"'
                && tokenName[strlen(tokenName) - 1] == '\"' ) {
                // Do some replacing.
                NSData *content = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithUTF8String:filePath]];
                NSString *contentString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
                NSString *stringToBeResplaced = [NSString stringWithUTF8String:tokenName];
                NSString *stringToBePutted = @"\"Hello\"";
                contentString = [contentString stringByReplacingOccurrencesOfString:stringToBeResplaced withString:stringToBePutted];
                [contentString writeToFile:[NSString stringWithUTF8String:filePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                printf("\t%d\t%s\n", cursor.kind, tokenName);
            }
            clang_disposeString(tokenSpelling);
            clang_disposeString(cursorSpelling);
        }
        clang_disposeTokens(tu, tokens, numTokens);
        clang_disposeIndex(index);
        clang_disposeTranslationUnit(tu);
        free(cursors);
    }
    return 0;
}
