//
//  SyntaxMapTests.swift
//
//  SyntaxMap
//  https://coteditor.com
//
//  Created by 1024jp on 2020-02-18.
//
//  ---------------------------------------------------------------------------
//
//  © 2020-2024 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import SyntaxMap

final class SyntaxMapTests: XCTestCase {
    
    func testMapLoad() throws {
        
        let urls = try XCTUnwrap(Bundle.module.urls(forResourcesWithExtension: "yml", subdirectory: "Syntaxes"))
        let maps = try SyntaxMap.loadMaps(at: urls)
        
        let expectedResult: [String: SyntaxMap] = [
            "Apache": SyntaxMap(extensions: ["conf"],
                                filenames: [".htaccess"],
                                interpreters: []),
            "Python": SyntaxMap(extensions: ["py"],
                                filenames: [],
                                interpreters: ["python", "python2", "python3"]),
        ]
        
        XCTAssertEqual(maps, expectedResult)
    }
}
