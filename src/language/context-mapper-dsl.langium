grammar ContextMapperDsl

hidden terminal WS: /\s+/;
terminal ID: /[_a-zA-Z][\w_]*/;
terminal STRING: /"(\\.|[^"\\])*"|'(\\.|[^'\\])*'/;

terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
terminal SL_COMMENT: /\/\/[^\n\r]*/;

terminal OPEN: '{';
terminal CLOSE: '}';

entry ContextMappingModel:
	(topComment=SL_COMMENT | topComment=ML_COMMENT)?
	(imports+=Import)*
	(map=ContextMap)?
	(boundedContexts+=BoundedContext)*
	(domains+=Domain)*
	(userRequirements+=UserRequirement)*
	(stakeholders+=Stakeholders)*
	(valueRegisters+=ValueRegister)*
;

Import:
	'import' importURI=STRING;

ContextMap:
	{infer ContextMap} // make sure there is always a context map
	'ContextMap' (name=ID)?
	OPEN
		('type' ('=')? type=ContextMapType)?
        ('state' ('=')? state=ContextMapState)?
		('contains' boundedContexts+=[BoundedContext] ("," boundedContexts+=[BoundedContext])*)*
		relationships+=Relationship*
	CLOSE
;

BoundedContext:
	(comment=ML_COMMENT | comment=SL_COMMENT)?
	'BoundedContext' name=ID (
		('implements' (implementedDomainParts+=[DomainPart]) ("," implementedDomainParts+=[DomainPart])*)?
		('realizes' (realizedBoundedContexts+=[BoundedContext]) ("," realizedBoundedContexts+=[BoundedContext])*)?
		('refines' refinedBoundedContext=[BoundedContext])?
	)
	(
		OPEN
			('domainVisionStatement' ('=')? domainVisionStatement=STRING)?
			('type' ('=')? type=BoundedContextType)?
			(('responsibilities' ('=')? responsibilities+=STRING) ("," responsibilities+=STRING)*)?
			('implementationTechnology' ('=')? implementationTechnology=STRING)?
			('knowledgeLevel' ('=')? knowledgeLevel=KnowledgeLevel)?
			('businessModel' ('=')? businessModel=STRING)?
            ('evolution' ('=')? evolution=Evolution)?
			(aggregates+=Aggregate)*
		CLOSE
	)?
;

DomainPart:
	Domain | Subdomain
;

Domain:
	'Domain' name=ID
	(
		OPEN
			(('domainVisionStatement' ('=')? domainVisionStatement=STRING)?
			(subdomains+=Subdomain)*)
		CLOSE
	)?
;

Subdomain:
	'Subdomain' name=ID ('supports' (supportedFeatures+=[UserRequirement]) ("," supportedFeatures+=[UserRequirement])*)?
	(
		OPEN
			(('type' ('=')? type=SubDomainType)?
			('domainVisionStatement' ('=')? domainVisionStatement=STRING)?)
		CLOSE
	)?
;

Relationship:
	(comment=ML_COMMENT | comment=SL_COMMENT)?
	SymmetricRelationship | UpstreamDownstreamRelationship
;

SymmetricRelationship:
	Partnership | SharedKernel
;

Partnership:
	(
		(participant1=[BoundedContext] '[''P'']' '<->' '[''P'']' participant2=[BoundedContext]) |
		('[''P'']' participant1=[BoundedContext] '<->' '[''P'']' participant2=[BoundedContext]) |
		(participant1=[BoundedContext] '[''P'']' '<->' participant2=[BoundedContext] '[''P'']') |
		('[''P'']' participant1=[BoundedContext] '<->' participant2=[BoundedContext] '[''P'']') |
		(participant1=[BoundedContext] 'Partnership' participant2=[BoundedContext])
	)
	(':' name=ID)?
	(OPEN
		('implementationTechnology' ('=')? implementationTechnology=STRING)?
	CLOSE)?
;

SharedKernel:
	(
		(participant1=[BoundedContext] '[''SK'']' '<->' '[''SK'']' participant2=[BoundedContext]) |
		('[''SK'']' participant1=[BoundedContext] '<->' '[''SK'']' participant2=[BoundedContext]) |
		(participant1=[BoundedContext] '[''SK'']' '<->' participant2=[BoundedContext] '[''SK'']') |
		('[''SK'']' participant1=[BoundedContext] '<->' participant2=[BoundedContext] '[''SK'']') |
		(participant1=[BoundedContext] 'Shared-Kernel' participant2=[BoundedContext]) |
		(participant1=[BoundedContext] '<->' participant2=[BoundedContext])
	)
	(':' name=ID)?
	(OPEN
		('implementationTechnology' ('=')? implementationTechnology=STRING)?
	CLOSE)?
;

UpstreamDownstreamRelationship:
	CustomerSupplierRelationship |
	(
		(
			(upstream=[BoundedContext] (('[''U'']') | ('['('U'',')?(upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)']')? '->' (('[''D'']') | ('['('D'',')?(downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)']')? downstream=[BoundedContext]) |
			(downstream=[BoundedContext] (('[''D'']') | ('['('D'',')?(downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)']')? '<-' (('[''U'']') | ('['('U'',')?(upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)']')? upstream=[BoundedContext]) |
			(upstream=[BoundedContext] ('['((upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)?']')?'Upstream-Downstream'('['((downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)?']')? downstream=[BoundedContext]) |
			(downstream=[BoundedContext] ('['((downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)?']')?'Downstream-Upstream'('['((upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)?']')? upstream=[BoundedContext])
		)
		(':' name=ID)?
		(OPEN (
			('implementationTechnology' ('=')? implementationTechnology=STRING)?
			(('exposedAggregates' ('=')? upstreamExposedAggregates+=[Aggregate]) ("," upstreamExposedAggregates+=[Aggregate])* (exposedAggregatesComment=SL_COMMENT)?)?
			('downstreamRights' ('=')? downstreamGovernanceRights=DownstreamGovernanceRights)?
		)
		CLOSE)?
	)
;

CustomerSupplierRelationship:
	(
		(
			(upstream=[BoundedContext] '['('U'',')?'S'(','(upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)?']' '->' '['('D'',')?'C'(','(downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)?']' downstream=[BoundedContext]) |
			(downstream=[BoundedContext] '['('D'',')?'C'(','(downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)?']' '<-' '['('U'',')?'S'(','(upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)?']' upstream=[BoundedContext]) |
			(downstream=[BoundedContext] ('['((downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)?']')?'Customer-Supplier'('['((upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)?']')? upstream=[BoundedContext]) |
			(upstream=[BoundedContext] ('['((upstreamRoles+=UpstreamRole) ("," upstreamRoles+=UpstreamRole)*)?']')?'Supplier-Customer'('['((downstreamRoles+=DownstreamRole) ("," downstreamRoles+=DownstreamRole)*)?']')? downstream=[BoundedContext])
		)
		(':' name=ID)?
		(OPEN (
			('implementationTechnology' ('=')? implementationTechnology=STRING)?
			(('exposedAggregates' ('=')? upstreamExposedAggregates+=[Aggregate]) ("," upstreamExposedAggregates+=[Aggregate])* (exposedAggregatesComment=SL_COMMENT)?)?
			('downstreamRights' ('=')? downstreamGovernanceRights=DownstreamGovernanceRights)?
		)
		CLOSE)?
	)
;

Aggregate:
	(comment=ML_COMMENT)?
  (doc=STRING)?
  "Aggregate" name=ID (OPEN
    (
    	(('responsibilities' ('=')? responsibilities+=STRING) ("," responsibilities+=STRING)*)?
    	(
    		(('useCases' ('=')? userRequirements+=[UseCase]) ("," userRequirements+=[UseCase])*) |
    		(('userStories' ('=')? userRequirements+=[UserStory]) ("," userRequirements+=[UserStory])*) |
    		((('features' | 'userRequirements') ('=')? userRequirements+=[UserRequirement]) ("," userRequirements+=[UserRequirement])*)
    	)?
    	('owner' ('=')? owner=[BoundedContext])?
    	('knowledgeLevel' ('=')? knowledgeLevel=KnowledgeLevel)?
    	(('likelihoodForChange' | 'structuralVolatility') ('=')? likelihoodForChange=Volatility)?
    	('contentVolatility' ('=')? contentVolatility=Volatility)?
    	('availabilityCriticality' ('=')? availabilityCriticality=Criticality)?
    	('consistencyCriticality' ('=')? consistencyCriticality=Criticality)?
    	('storageSimilarity' ('=')? storageSimilarity=Similarity)?
    	('securityCriticality' ('=')? securityCriticality=Criticality)?
    	('securityZone' ('=')? securityZone=STRING)?
    	('securityAccessGroup' ('=')? securityAccessGroup=STRING)?
    )
  CLOSE)?
;

UserRequirement:
	UseCase | UserStory
;

UseCase:
	'UseCase' name=ID (OPEN
		(('actor' ('=')? role=STRING)?
		('secondaryActors' ('=')? secondaryActors+=STRING ("," secondaryActors+=STRING)*)?
		('interactions' ('=')? features+=Feature ("," features+=Feature)*)?
		('benefit' ('=')? benefit=STRING)?
		('scope' ('=')? scope=STRING)?
		('level' ('=')? level=STRING)?)
	CLOSE)?
;

UserStory:
	'UserStory' name=ID ('split by' splittingStory=[UserStory])? (OPEN
		(('As a' | 'As an') role=STRING (features+=Feature)+ 'so that' benefit=STRING (valuation=StoryValuation)?)?
	CLOSE)?
;

Feature:
	NormalFeature | StoryFeature
;

NormalFeature:
	verb=(UserActivityDefaultVerb | STRING) (entityArticle='a' | entityArticle='an' | entityArticle='the')? entity=STRING ((entityAttributesPreposition='with its' | entityAttributesPreposition='with their') entityAttributes+=STRING ("," entityAttributes+=STRING)*)? ((containerEntityPreposition='in' | containerEntityPreposition='for' | containerEntityPreposition='to')(containerEntityArticle='a' | containerEntityArticle='an')? containerEntity=STRING)?
;

StoryFeature:
	'I want to' verb=(UserActivityDefaultVerb | STRING) (entityArticle='a' | entityArticle='an' | entityArticle='the')? entity=STRING ((entityAttributesPreposition='with its' | entityAttributesPreposition='with their') entityAttributes+=STRING ("," entityAttributes+=STRING)*)? ((containerEntityPreposition='in' | containerEntityPreposition='for' | containerEntityPreposition='to')(containerEntityArticle='a' | containerEntityArticle='an')? containerEntity=STRING)?
;

StoryValuation:
	'and that' promotedValues+=STRING (',' promotedValues+=STRING)* ('is' | 'are') 'promoted' (',')?
	'accepting that' harmedValues+=STRING (',' harmedValues+=STRING)* ('is' | 'are') ('reduced' | 'harmed')
;

terminal UserActivityDefaultVerb:
	'create' | 'read' | 'update' | 'delete'
;

Stakeholders:
	{infer Stakeholders} 'Stakeholders' ('of' (contexts+=[BoundedContext]) (',' contexts+=[BoundedContext])*)? (OPEN
		(
			(stakeholders+=AbstractStakeholder)*
		)
	CLOSE)?
;

AbstractStakeholder:
	StakeholderGroup | Stakeholder
;

StakeholderGroup:
	'StakeholderGroup' name=ID (OPEN
		(
			(stakeholders+=Stakeholder)*
		)
	CLOSE)?
;

Stakeholder:
	'Stakeholder' name=ID (OPEN
		(
			('influence' ('=')? influence=INFLUENCE)?
			('interest' ('=')? interest=INTEREST)?
			('description' ('=')? description=STRING)?
		)
	CLOSE)?
;

ValueRegister:
	'ValueRegister' name=ID ('for' context=[BoundedContext])? (OPEN
		(
			(valueClusters+=ValueCluster)*
			(values+=Value)*
			(valueEpics+=ValueEpic)*
			(valueNarratives+=ValueNarrative)*
			(valueWeightings+=ValueWeigthing)*
		)
	CLOSE)?
;

ValueCluster:
	'ValueCluster' name=ID (OPEN
		(
			(('core' ('=')? coreValue7000=CoreValue) | ('core' ('=')? coreValue=STRING))
			('demonstrator' ('=')? demonstrators+=STRING)*
			('relatedValue' ('=')? relatedValues+=STRING)*
			('opposingValue' ('=')? opposingValues+=STRING)*
			(values+=Value)*
			(elicitations+=ValueElicitation)*
		)
	CLOSE)?
;

Value:
	'Value' name=ID (OPEN
		(
			(coreValue?='isCore')?
			('demonstrator' ('=')? demonstrators+=STRING)*
			('relatedValue' ('=')? relatedValues+=STRING)*
			('opposingValue' ('=')? opposingValues+=STRING)*
			(elicitations+=ValueElicitation)*
		)
	CLOSE)?
;

// Q: table B.1  abbilden? if, how?

ValueElicitation:
	('Stakeholder'|'Stakeholders') stakeholder=[AbstractStakeholder] (OPEN
		(
			('priority' ('=')? priority=PRIORITY)?
			('impact' ('=')? impact=IMPACT)?
			('consequences' (consequences+=Consequence)+)?
		)
	CLOSE)?
;


ValueEpic:
	'ValueEpic' name=ID (OPEN
    	(
    		'As a' stakeholder=[AbstractStakeholder] 'I value' value=STRING 'as demonstrated in'
    		(('realization of' realizedValues+=STRING)+
    		('reduction of' reducedValues+=STRING)+)
    	)
	CLOSE)?
;

ValueNarrative:
	'ValueNarrative' name=ID (OPEN
		(
			'When the SOI executes' feature=STRING ','
	    	'stakeholders expect it to promote, protect or create' promotedValues=STRING ','
	    	'possibly degrading or prohibiting' harmedValues=STRING
	    	'with the following externally observable and/or internally auditable behavior:' preAndPostConditions=STRING
		)
	CLOSE)
;

ValueWeigthing:
	'ValueWeigthing' name=ID (OPEN
		(
			'In the context of the SOI,'
    		'stakeholder' stakeholder=[AbstractStakeholder] 'values' value1=STRING 'more than' value2=STRING
    		'expecting benefits such as' benefits=STRING
    		'running the risk of harms such as' harms=STRING
		)
	CLOSE)
;

Consequence:
	(type='good'|type='bad'|type='neutral') consequence=STRING action=Action?
;

Action:
	'action' action=STRING type=('ACT'|'MONITOR'|STRING)
;


UpstreamRole:
	PUBLISHED_LANGUAGE='PL' | OPEN_HOST_SERVICE='OHS'
;

DownstreamRole:
	ANTICORRUPTION_LAYER='ACL' | CONFORMIST='CF'
;

ContextMapState:
	UNDEFINED='UNDEFINED' | AS_IS='AS_IS' | TO_BE='TO_BE'
;

ContextMapType:
	UNDEFINED='UNDEFINED' | SYSTEM_LANDSCAPE='SYSTEM_LANDSCAPE' | ORGANIZATIONAL='ORGANIZATIONAL'
;

BoundedContextType:
	UNDEFINED='UNDEFINED' | FEATURE='FEATURE' | APPLICATION='APPLICATION' | SYSTEM='SYSTEM' | TEAM='TEAM'
;

SubDomainType:
	UNDEFINED='UNDEFINED' | CORE_DOMAIN='CORE_DOMAIN' | SUPPORTING_DOMAIN='SUPPORTING_DOMAIN' | GENERIC_SUBDOMAIN='GENERIC_SUBDOMAIN'
;

DownstreamGovernanceRights:
	INFLUENCER='INFLUENCER' | OPINION_LEADER='OPINION_LEADER' | VETO_RIGHT='VETO_RIGHT' | DECISION_MAKER='DECISION_MAKER' | MONOPOLIST='MONOPOLIST'
;

KnowledgeLevel:
	META='META' | CONCRETE='CONCRETE'
;

Volatility:
	UNDEFINED='UNDEFINED' | NORMAL='NORMAL'| RARELY='RARELY' | OFTEN='OFTEN'
;

Criticality:
	UNDEFINED='UNDEFINED' | NORMAL='NORMAL' | HIGH='HIGH' | LOW='LOW'
;

Similarity:
	UNDEFINED='UNDEFINED' | NORMAL='NORMAL' | HUGE='HUGE' | TINY='TINY'
;

Evolution:
	UNDEFINED='UNDEFINED' | GENESIS='GENESIS' | CUSTOM_BUILT='CUSTOM_BUILT' | PRODUCT='PRODUCT' | COMMODITY='COMMODITY'
;

INFLUENCE:
	UNDEFINED='UNDEFINED' | HIGH='HIGH' | MEDIUM='MEDIUM' | LOW='LOW'
;

INTEREST:
	UNDEFINED='UNDEFINED' | HIGH='HIGH' | MEDIUM='MEDIUM' | LOW='LOW'
;

PRIORITY:
	UNDEFINED='UNDEFINED' | HIGH='HIGH' | MEDIUM='MEDIUM' | LOW='LOW'
;

IMPACT:
	UNDEFINED='UNDEFINED' | HIGH='HIGH' | MEDIUM='MEDIUM' | LOW='LOW'
;

CoreValue:
	UNDEFINED='UNDEFINED' | AUTONOMY='AUTONOMY' | CARE='CARE' | CONTROL='CONTROL' | FAIRNESS='FAIRNESS' | INCLUSIVENESS='INCLUSIVENESS' | INNOVATION='INNOVATION' | PERFECTION='PERFECTION' | PRIVACY='PRIVACY' | RESPECT='RESPECT' | SUSTAINABILITY='SUSTAINABILITY' | TRANSPARENCY='TRANSPARENCY' | TRUST='TRUST'
;

