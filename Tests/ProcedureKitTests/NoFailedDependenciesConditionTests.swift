//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit

class NoFailedDependenciesConditionTests: ProcedureKitTestCase {

    func test__procedure_with_no_dependencies_succeeds() {
        procedure.add(condition: NoFailedDependenciesCondition())
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
    }

    func test__procedure_with_successful_dependency_succeeds() {
        let dependency = TestProcedure()
        procedure.add(dependency: dependency)
        procedure.add(condition: NoFailedDependenciesCondition())
        wait(for: procedure, dependency)
        PKAssertProcedureFinished(procedure)
    }

    func test__procedure_with_cancelled_dependency_fails() {
        let dependency = createCancellingProcedure()
        procedure.add(dependency: dependency)
        procedure.add(condition: NoFailedDependenciesCondition())
        wait(for: procedure, dependency)
        PKAssertProcedureError(procedure, ProcedureKitError.dependenciesCancelled())
    }

    func test__procedure_with_mixture_fails() {
        let dependency1 = TestProcedure()
        let dependency2 = createCancellingProcedure()

        procedure.add(dependency: dependency1)
        procedure.add(dependency: dependency2)
        procedure.add(condition: NoFailedDependenciesCondition())
        wait(for: procedure, dependency1, dependency2)
        PKAssertProcedureError(procedure, ProcedureKitError.dependenciesCancelled())
    }

    func test__procedure_with_errored_dependency_fails() {
        let dependency = TestProcedure(error: TestError())
        procedure.add(dependency: dependency)
        procedure.add(condition: NoFailedDependenciesCondition())
        wait(for: procedure, dependency)
        PKAssertProcedureError(procedure, ProcedureKitError.dependenciesFailed())
    }

    func test__procedure_with_group_dependency_with_errored_child_fails() {
        let dependency = GroupProcedure(operations: [TestProcedure(error: TestError())])
        procedure.add(dependency: dependency)
        procedure.add(condition: NoFailedDependenciesCondition())
        wait(for: procedure, dependency)
        PKAssertProcedureError(procedure, ProcedureKitError.dependenciesFailed())
    }

    func test__procedure_with_ignored_cancellations() {
        let dependency = createCancellingProcedure()
        procedure.add(dependency: dependency)
        procedure.add(condition: NoFailedDependenciesCondition(ignoreCancellations: true))
        wait(for: procedure, dependency)
        PKAssertProcedureCancelled(procedure)
    }

    func test__procedure_with_failures_and_cancellations_with_ignore_cancellations() {

        let dependency1 = createCancellingProcedure()
        procedure.add(dependency: dependency1)

        let dependency2 = TestProcedure(error: TestError())
        procedure.add(dependency: dependency2)

        let dependency3 = TestProcedure()
        procedure.add(dependency: dependency3)

        procedure.add(condition: NoFailedDependenciesCondition(ignoreCancellations: true))
        wait(for: procedure, dependency1, dependency2, dependency3)
        PKAssertProcedureCancelled(procedure)
        PKAssertProcedureError(procedure, ProcedureKitError.dependenciesCancelled())
    }
}
