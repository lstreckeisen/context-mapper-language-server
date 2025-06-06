import { ContextMapperSemanticTokenProvider } from '../ContextMapperSemanticTokenProvider.js'
import { ValueNarrative } from '../../generated/ast.js'
import { SemanticTokenAcceptor } from 'langium/lsp'
import { highlightKeyword, highlightString, highlightTypeDeclaration } from '../HighlightingHelper.js'

export class ValueNarrativeSemanticTokenProvider implements ContextMapperSemanticTokenProvider<ValueNarrative> {
  highlight (node: ValueNarrative, acceptor: SemanticTokenAcceptor) {
    highlightTypeDeclaration(node, acceptor, 'ValueNarrative')

    highlightKeyword(node, acceptor, 'When the SOI executes')
    highlightString(node, acceptor, 'feature')

    highlightKeyword(node, acceptor, 'stakeholders expect it to promote, protect or create')
    highlightString(node, acceptor, 'promotedValues')

    highlightKeyword(node, acceptor, 'possibly degrading or prohibiting')
    highlightString(node, acceptor, 'harmedValues')

    highlightKeyword(node, acceptor, 'with the following externally observable and/or internally auditable behavior:')
    highlightString(node, acceptor, 'preAndPostConditions')
  }
}
