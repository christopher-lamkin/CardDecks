//
//
// CDXStorage.m
//
//
// Copyright (c) 2009-2010 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CDXStorage.h"
#import "CDXDictionarySerializerUtils.h"
#import <sys/time.h>

#undef ql_component
#define ql_component lcl_cStorage


static NSMutableArray *storageDeferredUpdates = nil;
static NSMutableArray *storageDeferredRemoves = nil;

@implementation CDXStorage

+ (void)initialize {
    qltrace();
    storageDeferredUpdates = [[NSMutableArray alloc] init];
    storageDeferredRemoves = [[NSMutableArray alloc] init];
}

+ (NSDictionary *)readDictionaryFromFile:(NSString *)file {
    qltrace(@"file %@", file);
    
    // create the file name
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", file];
    
    // first, look in 'Documents' folder
    {
        NSString *folder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *path = [folder stringByAppendingPathComponent:fileName];
        qltrace(@"path1 %@", path);
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dictionary != nil) {
            return dictionary;
        }
    }
    
    // second, look in application bundle
    {
        NSString *folder = [NSHomeDirectory() stringByAppendingPathComponent:@"CardDecks2.app"];
        NSString *path = [folder stringByAppendingPathComponent:fileName];
        qltrace(@"path2 %@", path);
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dictionary != nil) {
            return dictionary;
        }
    }
    
    return nil;
}

+ (void)writeDictionary:(NSDictionary *)dictionary toFile:(NSString *)file {
    qltrace(@"file %@", file);
    
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", file];
    
    // update file in 'Documents' folder
    NSString *folder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [folder stringByAppendingPathComponent:fileName];
    qltrace(@"path %@", path);
    
    [dictionary writeToFile:path atomically:YES];        
}

+ (void)removeFile:(NSString *)file {
    qltrace(@"file %@", file);
    
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", file];
    
    // remove file in 'Documents' folder
    NSString *folder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [folder stringByAppendingPathComponent:fileName];
    qltrace(@"path %@", path);
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

+ (NSString *)fileWithSuffix:(NSString *)suffix {
    struct timeval now;
    struct tm now_tm;
    
    gettimeofday(&now, NULL);
    localtime_r(&now.tv_sec, &now_tm);
    return [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d%06d%@", 
            now_tm.tm_year + 1900,
            now_tm.tm_mon + 1,
            now_tm.tm_mday,
            now_tm.tm_hour,
            now_tm.tm_min,
            now_tm.tm_sec,
            now.tv_usec,
            suffix];
}

+ (void)updateStorageObject:(NSObject<CDXStorageObject> *)object deferred:(BOOL)deferred {
    qltrace(@"%@:%d", [object storageObjectName], deferred);
    
    if (object == nil) {
        return;
    }
    
    [object retain];
    
    if (deferred) {
        [CDXStorage cancelDeferredActionForStorageObject:object];
        [storageDeferredUpdates addObject:object];
    } else {
        [CDXStorage writeDictionary:[object storageObjectAsDictionary] toFile:[object storageObjectName]];
    }
    
    [object release];
}

+ (void)removeStorageObject:(NSObject<CDXStorageObject> *)object deferred:(BOOL)deferred {
    qltrace(@"%@:%d", [object storageObjectName], deferred);
    
    if (object == nil) {
        return;
    }
    
    [object retain];
    
    if (deferred) {
        [CDXStorage cancelDeferredActionForStorageObject:object];
        [storageDeferredRemoves addObject:object];
    } else {
        [CDXStorage removeFile:[object storageObjectName]];
    }
    
    [object release];
}

+ (void)drainDeferredActionForStorageObject:(NSObject<CDXStorageObject> *)object {
    qltrace(@"%@ (updates:%d removes:%d)", [object storageObjectName], [storageDeferredUpdates count], [storageDeferredRemoves count]);
    
    [object retain];
    
    NSString *storageObjectName = [object storageObjectName];
    NSUInteger indexPlus1;
    
    indexPlus1 = [storageDeferredUpdates count];
    for (;indexPlus1 > 0; indexPlus1--) {
        NSObject<CDXStorageObject> *object = (NSObject<CDXStorageObject> *)[storageDeferredUpdates objectAtIndex:indexPlus1-1];
        if (storageObjectName == nil || [[object storageObjectName] isEqualToString:storageObjectName]) {
            [CDXStorage updateStorageObject:object deferred:NO];
            [storageDeferredUpdates removeObjectAtIndex:indexPlus1-1];
        }
    }
    if ([storageDeferredUpdates count] == 0) {
        [storageDeferredUpdates release];
        storageDeferredUpdates = [[NSMutableArray alloc] init];
    }
    
    indexPlus1 = [storageDeferredRemoves count];
    for (;indexPlus1 > 0; indexPlus1--) {
        NSObject<CDXStorageObject> *object = (NSObject<CDXStorageObject> *)[storageDeferredRemoves objectAtIndex:indexPlus1-1];
        if (storageObjectName == nil || [[object storageObjectName] isEqualToString:storageObjectName]) {
            [CDXStorage removeStorageObject:object deferred:NO];
            [storageDeferredRemoves removeObjectAtIndex:indexPlus1-1];
        }
    }
    if ([storageDeferredRemoves count] == 0) {
        [storageDeferredRemoves release];
        storageDeferredRemoves = [[NSMutableArray alloc] init];
    }
    
    [object release];
}

+ (void)cancelDeferredActionForStorageObject:(NSObject<CDXStorageObject> *)object {
    qltrace(@"%@", [object storageObjectName]);
    
    [object retain];
    
    NSString *storageObjectName = [object storageObjectName];
    NSUInteger indexPlus1;
    
    indexPlus1 = [storageDeferredUpdates count];
    for (;indexPlus1 > 0; indexPlus1--) {
        NSObject<CDXStorageObject> *object = (NSObject<CDXStorageObject> *)[storageDeferredUpdates objectAtIndex:indexPlus1-1];
        if ([[object storageObjectName] isEqualToString:storageObjectName]) {
            [storageDeferredUpdates removeObjectAtIndex:indexPlus1-1];
        }
    }
    
    indexPlus1 = [storageDeferredRemoves count];
    for (;indexPlus1 > 0; indexPlus1--) {
        NSObject<CDXStorageObject> *object = (NSObject<CDXStorageObject> *)[storageDeferredRemoves objectAtIndex:indexPlus1-1];
        if ([[object storageObjectName] isEqualToString:storageObjectName]) {
            [storageDeferredRemoves removeObjectAtIndex:indexPlus1-1];
        }
    }
    
    [object release];
}

+ (void)drainAllDeferredActions {
    qltrace();
    [CDXStorage drainDeferredActionForStorageObject:nil];
}

@end



