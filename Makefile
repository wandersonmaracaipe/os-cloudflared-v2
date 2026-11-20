PLUGIN_NAME=		cloudflared-v2
PLUGIN_VERSION=		2.0.0
PLUGIN_COMMENT=		Cloudflare Zero Trust Tunnel integration
PLUGIN_MAINTAINER=	wanderson@valuor.com.br
PLUGIN_DEPENDS=		cloudflared
PLUGIN_CONFLICTS=	os-cloudflared os-cloudflared-devel

.include "../../Mk/plugins.mk"
