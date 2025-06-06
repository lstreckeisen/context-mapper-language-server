import { ContextMapperGenerator } from './ContextMapperGenerator.js'
import path from 'node:path'
import fs from 'node:fs'
import { ContextMappingModel } from '../../generated/ast.js'
import { ComponentDiagramGenerator } from './plantuml/ComponentDiagramGenerator.js'
import { CancellationToken } from 'vscode-languageserver'

export class PlantUMLGenerator implements ContextMapperGenerator {
  async generate (model: ContextMappingModel, filePath: string, args: unknown[], cancelToken: CancellationToken): Promise<string[]> {
    // there must not be any extra spaces especially at the start, since the path will be treated as relative otherwise
    const destination = (args[0] as string)?.trim()
    if (destination == null || destination === '') {
      throw Error('Destination must be specified')
    }

    if (cancelToken.isCancellationRequested) {
      return []
    }
    const fileName = filePath.split('/').pop()!.split('.')[0]

    if (!fs.existsSync(destination)) {
      await fs.promises.mkdir(destination, { recursive: true })
    }

    const diagrams: string[] = []

    const componentDiagram = await this.generateComponentDiagram(model, destination, fileName)
    if (componentDiagram) {
      diagrams.push(componentDiagram)
    }

    return diagrams
  }

  private async generateComponentDiagram (model: ContextMappingModel, destination: string, fileName: string): Promise<string | undefined> {
    if (model.contextMap.length === 0) {
      return
    }

    const generator = new ComponentDiagramGenerator()
    const diagram = generator.createDiagram(model.contextMap[0])
    return await this.createFile(destination, fileName, diagram)
  }

  private async createFile (destination: string, fileName: string, content: string) {
    const filePath = `${path.join(destination, fileName)}.puml`
    await fs.promises.writeFile(filePath, content)
    return filePath
  }
}