//
//  A11yAssertions.swift
//  A11yUITests
//
//  Created by Rob Whitaker on 28/03/2021.
//

import XCTest

class A11yAssertions {

    // MARK: - Test Runner

    func a11y(_ tests: [A11yTests],
              _ elements: [A11yElement],
              _ minLength: Int,
              _ file: StaticString,
              _ line: UInt) {

        for element in elements.filter( { !$0.shouldIgnore } ) {

            if tests.contains(.minimumSize) {
                validSizeFor(element,
                             file,
                             line)
            }

            if tests.contains(.minimumInteractiveSize) {
                validSizeFor(interactiveElement: element,
                             file,
                             line)
            }

            if tests.contains(.labelPresence) {
                validLabelFor(element,
                              minLength,
                              file,
                              line)
            }

            if tests.contains(.buttonLabel) {
                validLabelFor(interactiveElement: element,
                              minLength,
                              file,
                              line)
            }

            if tests.contains(.imageLabel) {
                validLabelFor(image: element,
                              minLength,
                              file,
                              line)
            }

            if tests.contains(.labelLength) {
                labelLength(element,
                            file,
                            line)
            }

            if tests.contains(.imageTrait) {
                validTraitFor(image: element,
                              file: file,
                              line: line)
            }

            for element2 in elements {
                if tests.contains(.duplicated) {
                    duplicatedLabels(element,
                                     element2,
                                     file,
                                     line)
                }
            }
        }
    }

    // MARK: - Tests

    func validSizeFor(_ element: A11yElement,
                      _ file: StaticString,
                      _ line: UInt) {

        guard !element.shouldIgnore else { return }

        XCTAssertGreaterThanOrEqual(element.frame.size.height,
                                    18,
                                    "Accessibility Failure: Element not tall enough: \(element.description)",
                                    file: file,
                                    line: line)

        XCTAssertGreaterThanOrEqual(element.frame.size.width,
                                    18,
                                    "Accessibility Failure: Element not wide enough: \(element.description)",
                                    file: file,
                                    line: line)
    }

    func validLabelFor(_ element: A11yElement,
                       _ length: Int = 2,
                       _ file: StaticString,
                       _ line: UInt) {

        guard !element.shouldIgnore,
              element.type != .cell else { return }

        XCTAssertGreaterThan(element.label.count,
                             length,
                             "Accessibility Failure: Label not meaningful: \(element.description). Minimum length: \(length)",
                             file: file,
                             line: line)
    }

    func validLabelFor(interactiveElement element: A11yElement,
                       _ length: Int = 2,
                       _ file: StaticString,
                       _ line: UInt) {

        guard element.isControl else { return }

        validLabelFor(element,
                      length,
                      file,
                      line)

        // TODO: Localise this check
        XCTAssertFalse(element.label.containsCaseInsensitive("button"),
                       "Accessibility Failure: Button should not contain the word button in the accessibility label, set this as an accessibility trait: \(element.description)",
                       file: file,
                       line: line)

        if let first = element.label.first {
            XCTAssert(first.isUppercase,
                      "Accessibility Failure: Buttons should begin with a capital letter: \(element.description)",
                      file: file,
                      line: line)
        }

        XCTAssertNil(element.label.range(of: "."),
                     "Accessibility failure: Button accessibility labels shouldn't contain punctuation: \(element.description)",
                     file: file,
                     line: line)
    }

    func validLabelFor(image: A11yElement,
                       _ length: Int = 2,
                       _ file: StaticString,
                       _ line: UInt) {

        guard image.type == .image else { return }

        validLabelFor(image,
                      length,
                      file,
                      line)

        // TODO: Localise this test
        let avoidWords = ["image", "picture", "graphic", "icon"]
        image.label.doesNotContain(avoidWords,
                                   "Accessibility Failure: Images should not contain image words in the accessibility label, set the image accessibility trait: \(image.description)",
                                   file,
                                   line)

        let possibleFilenames = ["_", "-", ".png", ".jpg", ".jpeg", ".pdf", ".avci", ".heic", ".heif"]
        image.label.doesNotContain(possibleFilenames,
                                   "Accessibility Failure: Image file name is used as the accessibility label: \(image.description)",
                                   file,
                                   line)
    }

    func validTraitFor(image: A11yElement,
                       file: StaticString,
                       line: UInt) {

        guard image.type == .image else { return }
        XCTAssert(image.traits?.contains(.image) ?? false,
                  "Accessibility Failure: Image should have Image trait: \(image.description)",
                  file: file,
                  line: line)
    }

    func labelLength(_ element: A11yElement,
                     _ file: StaticString,
                     _ line: UInt) {

        guard element.type != .staticText,
              element.type != .textView,
              !element.shouldIgnore else { return }

        XCTAssertLessThanOrEqual(element.label.count,
                                 40,
                                 "Accessibility Failure: Label is too long: \(element.description)",
                                 file: file,
                                 line: line)
    }

    func validSizeFor(interactiveElement: A11yElement,
                      _ file: StaticString,
                      _ line: UInt) {

        guard interactiveElement.isInteractive else { return }

        XCTAssertGreaterThanOrEqual(interactiveElement.frame.size.height,
                                    44,
                                    "Accessibility Failure: Interactive element not tall enough: \(interactiveElement.description)",
                                    file: file,
                                    line: line)

        XCTAssertGreaterThanOrEqual(interactiveElement.frame.size.width,
                                    44,
                                    "Accessibility Failure: Interactive element not wide enough: \(interactiveElement.description)",
                                    file: file,
                                    line: line)
    }

    func duplicatedLabels(_ element1: A11yElement,
                          _ element2: A11yElement,
                          _ file: StaticString,
                          _ line: UInt) {

        guard element1.isControl,
              element2.isControl,
              element1.underlyingElement != element2.underlyingElement else { return }

        XCTAssertNotEqual(element1.label,
                          element2.label,
                          "Accessibility Failure: Elements have duplicated labels: \(element1.description), \(element2.description)",
                          file: file,
                          line: line)
    }
}
