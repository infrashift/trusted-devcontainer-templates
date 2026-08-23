// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://infrashift.github.io',
	base: '/trusted-devcontainer-templates',
	integrations: [
		starlight({
			title: 'Trusted Templates',
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/infrashift/trusted-devcontainer-templates' },
			],
			editLink: {
				baseUrl: 'https://github.com/infrashift/trusted-devcontainer-templates/edit/main/docs/',
			},
			customCss: ['./src/styles/custom.css'],
			sidebar: [
				{ label: 'Getting Started', slug: 'getting-started' },
				{
					label: 'Templates',
					items: [
						{ label: 'Template Catalog', slug: 'templates' },
						{ label: 'Ansible + CUE', slug: 'templates/ansible-cue' },
						{ label: '.NET + Node.js', slug: 'templates/dotnet-node' },
						{ label: 'Go + CUE', slug: 'templates/go-cue' },
						{ label: 'Java', slug: 'templates/java' },
						{ label: 'Python', slug: 'templates/python' },
					],
				},
				{
					label: 'Trust & Security',
					items: [
						{ label: 'Overview', slug: 'trust' },
						{ label: 'Supply Chain', slug: 'trust/supply-chain' },
						{ label: 'Verification', slug: 'trust/verification' },
						{ label: 'OPA Policy Gate', slug: 'trust/opa-policy' },
					],
				},
				{
					label: 'Release Pipeline',
					items: [
						{ label: 'Pipeline Overview', slug: 'pipeline' },
						{ label: 'Release Workflow', slug: 'pipeline/release' },
						{ label: 'PR Validation', slug: 'pipeline/pr-validation' },
						{ label: 'Containerfile Sync', slug: 'pipeline/containerfile-sync' },
					],
				},
				{
					label: 'Architecture Decisions',
					items: [
						{ label: 'ADR Index', slug: 'decisions' },
						{ label: 'ADR-001: UBI9 Base Image', slug: 'decisions/adr-001-ubi9-base-image' },
						{ label: 'ADR-002: Shared Containerfile', slug: 'decisions/adr-002-shared-containerfile' },
						{ label: 'ADR-003: Non-Root dev User', slug: 'decisions/adr-003-non-root-dev-user' },
						{ label: 'ADR-004: OPA Policy Gate', slug: 'decisions/adr-004-opa-policy-gate' },
						{ label: 'ADR-005: Dual Signing', slug: 'decisions/adr-005-dual-signing' },
						{ label: 'ADR-006: Trusted Features Only', slug: 'decisions/adr-006-trusted-features-only' },
						{ label: 'ADR-007: Fedora 43 Base Image', slug: 'decisions/adr-007-fedora43-base-image' },
						{ label: 'ADR-008: Ansible Bootstrap Contract', slug: 'decisions/adr-008-ansible-bootstrap-contract' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'Architecture', slug: 'reference/architecture' },
						{ label: 'Contributing', slug: 'reference/contributing' },
						{ label: 'Roadmap', slug: 'reference/roadmap' },
					],
				},
			],
		}),
	],
});
