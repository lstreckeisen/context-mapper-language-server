import { afterEach, beforeAll, describe, expect, test } from 'vitest'
import { EmptyFileSystem, type LangiumDocument } from 'langium'
import { clearDocuments, parseHelper } from 'langium/test'
import { createContextMapperDslServices } from '../../src/language/ContextMapperDslModule.js'
import { ContextMappingModel, isSharedKernel } from '../../src/language/generated/ast.js'
import { checkDocumentValid } from '../TestHelper.js'

let services: ReturnType<typeof createContextMapperDslServices>
let parse: ReturnType<typeof parseHelper<ContextMappingModel>>
let document: LangiumDocument<ContextMappingModel> | undefined

beforeAll(async () => {
  services = createContextMapperDslServices(EmptyFileSystem)
  parse = parseHelper<ContextMappingModel>(services.ContextMapperDsl)

  // activate the following if your linking test requires elements from a built-in library, for example
  // await services.shared.workspace.WorkspaceManager.initializeWorkspace([]);
})

afterEach(async () => {
  document && await clearDocuments(services.shared, [document])
})

describe('Bounded context linking tests', () => {
  test('linking of bounded contexts in context map', async () => {
    document = await parse(`
            ContextMap {
                TestContext [SK] <-> [SK] FirstContext
            }
            BoundedContext FirstContext
            BoundedContext TestContext
        `)

    const errors = checkDocumentValid(document)
    expect(errors == null).toBeTruthy()

    const referencedContexts: Array<string | undefined> = []

    document.parseResult.value.contextMaps[0].relationships.forEach(r => {
      if (isSharedKernel(r)) {
        referencedContexts.push(r.participant1.ref?.name)
        referencedContexts.push(r.participant2.ref?.name)
      }
    })

    expect(referencedContexts.length).toBe(2)
    expect(referencedContexts).toEqual(['TestContext', 'FirstContext'])
  })
})
